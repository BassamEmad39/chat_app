import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/models/user_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // ------------------ Users ------------------
  Stream<List<UserModel>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    });
  }

  Future<bool> userExists(String email) async {
    final result = await _firestore
        .collection("Users")
        .where("email", isEqualTo: email)
        .get();
    return result.docs.isNotEmpty;
  }

  Future<String?> getUserIdByEmail(String email) async {
    final snap = await _firestore
        .collection('Users')
        .where('email', isEqualTo: email)
        .get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.id;
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('Users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ------------------ Private Messages ------------------
  Future<void> sendPrivateMessage(String receiverId, String message) async {
    if (currentUserId == null) return;

    final timestamp = Timestamp.now();
    final currentUser = await getUserById(currentUserId!);
    
    List<String> ids = [currentUserId!, receiverId]..sort();
    String chatRoomId = ids.join('_');

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
          'senderId': currentUserId,
          'senderEmail': _auth.currentUser!.email,
          'senderUsername': currentUser?.username ?? 'Unknown',
          'message': message,
          'timestamp': timestamp,
        });
  }

  Stream<QuerySnapshot> getPrivateMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId]..sort();
    String chatRoomId = ids.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // ------------------ Groups ------------------
  Future<String> createGroup(String name, List<String> members) async {
    final doc = await _firestore.collection('groups').add({
      'name': name,
      'members': members,
      'admins': [currentUserId],
      'createdAt': Timestamp.now(),
    });
    return doc.id;
  }

  Stream<QuerySnapshot> getUserGroups() {
    if (currentUserId == null) return const Stream.empty();
    return _firestore
        .collection('groups')
        .where('members', arrayContains: currentUserId)
        .snapshots();
  }

  Stream<QuerySnapshot> getGroupMessages(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> sendGroupMessage(String groupId, String message) async {
    if (currentUserId == null) return;
    final timestamp = Timestamp.now();
    final currentUser = await getUserById(currentUserId!);

    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .add({
          'senderId': currentUserId,
          'senderEmail': _auth.currentUser!.email,
          'senderUsername': currentUser?.username ?? 'Unknown',
          'message': message,
          'timestamp': timestamp,
        });
  }

  Future<bool> addMemberToGroup(String groupId, String email) async {
    final exists = await userExists(email);
    if (!exists) return false;

    final userId = await getUserIdByEmail(email);
    if (userId == null) return false;

    await _firestore.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayUnion([userId]),
    });
    return true;
  }

  // ------------------ Members Stream & Admins ------------------
  Stream<List<Map<String, dynamic>>> getGroupMembersStream(String groupId) {
    return _firestore.collection('groups').doc(groupId).snapshots().asyncMap((
      doc,
    ) async {
      final data = doc.data();
      if (data == null) return [];

      final memberIds = List<String>.from(data['members'] ?? []);
      final adminIds = List<String>.from(data['admins'] ?? []);

      List<Map<String, dynamic>> members = [];
      for (var id in memberIds) {
        final user = await getUserById(id);
        if (user == null) continue;

        final isAdmin = adminIds.contains(id);
        final canManage = adminIds.contains(currentUserId);
        members.add({
          'id': id,
          'email': user.email,
          'username': user.username,
          'isAdmin': isAdmin,
          'canManage': canManage,
        });
      }
      return members;
    });
  }

  Future<void> removeMemberFromGroup(String groupId, String memberId) async {
    await _firestore.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([memberId]),
    });
  }

  Future<void> makeAdmin(String groupId, String memberId) async {
    await _firestore.collection('groups').doc(groupId).update({
      'admins': FieldValue.arrayUnion([memberId]),
    });
  }

  Future<void> revokeAdmin(String groupId, String memberId) async {
    await _firestore.collection('groups').doc(groupId).update({
      'admins': FieldValue.arrayRemove([memberId]),
    });
  }
}