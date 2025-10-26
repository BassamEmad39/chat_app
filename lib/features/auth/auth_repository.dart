import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final userDoc = await _firestore.collection('Users').doc(user.uid).get();
    if (userDoc.exists) {
      return UserModel.fromMap(userDoc.data()!);
    }
    return null;
  }

  Future<bool> isUsernameAvailable(String username) async {
    final query = await _firestore
        .collection('Users')
        .where('username', isEqualTo: username)
        .get();
    return query.docs.isEmpty;
  }

  Stream<UserModel?> get userStream {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final userDoc = await _firestore.collection('Users').doc(user.uid).get();
      return userDoc.exists ? UserModel.fromMap(userDoc.data()!) : null;
    });
  }
}