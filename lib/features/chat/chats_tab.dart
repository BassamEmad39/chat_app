import 'dart:developer';
import 'package:chat_app/components/buttons/main_button.dart';
import 'package:chat_app/components/inputs/name_text_form_field.dart';
import 'package:chat_app/components/user_tile.dart';
import 'package:chat_app/features/chat/chat_services.dart';
import 'package:chat_app/features/chat/private_chat_page.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatsTab extends StatefulWidget {
  final ChatService chatServices;
  const ChatsTab({super.key, required this.chatServices});

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  User? getCurrentUser() => FirebaseAuth.instance.currentUser;
  final List<UserModel> _allUsers = [];
  bool _isLoading = true;
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _loadAllUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadAllUsers() async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .get();
      
      final currentUserId = getCurrentUser()?.uid;
      if (currentUserId == null) return;

      _allUsers.clear();
      
      for (var doc in usersSnapshot.docs) {
        final user = UserModel.fromMap(doc.data());
        if (user.uid != currentUserId) {
          _allUsers.add(user);
        }
      }

      setState(() {
        _isLoading = false;
        _filteredUsers = List.from(_allUsers);
      });
    } catch (e) {
      log('Error loading users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startChatWithUser(UserModel user) async {
    final currentUserId = getCurrentUser()?.uid;
    if (currentUserId == null) return;

    // Mark messages as read before opening chat
    List<String> ids = [currentUserId, user.uid]..sort();
    String chatRoomId = ids.join('_');
    await widget.chatServices.markMessagesAsRead(chatRoomId, currentUserId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrivateChatPage(
          receiverEmail: user.email,
          receiverID: user.uid,
          receiverUsername: user.username,
        ),
      ),
    );
    // No need to refresh manually - streams will handle it
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      _searchController.clear();
      _filteredUsers = List.from(_allUsers);
    });
  }

  void _searchUsers(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredUsers = List.from(_allUsers);
      });
    } else {
      setState(() {
        _filteredUsers = _allUsers.where((user) {
          return user.username.toLowerCase().contains(query.toLowerCase()) ||
                 user.email.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _showSearch ? 'Search Users' : 'Recent Chats',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: Icon(
                  _showSearch ? Icons.close : Icons.search,
                  color: const Color(0xFF06B6D4),
                ),
                onPressed: _toggleSearch,
              ),
            ],
          ),
        ),

        if (_showSearch) ...[
          // Search Mode
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: NameTextFormField(
              controller: _searchController,
              hintText: 'Search by username or email...',
              onChanged: _searchUsers,
            ),
          ),
          _buildSearchResults(),
        ] else ...[
          // Recent Chats Mode - Now using StreamBuilder for real-time updates
          _buildRecentChatsStream(),
        ],
      ],
    );
  }

  Widget _buildSearchResults() {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              _searchController.text.isEmpty
                  ? 'All users (${_filteredUsers.length})'
                  : 'Found ${_filteredUsers.length} user${_filteredUsers.length == 1 ? '' : 's'}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          
          Expanded(
            child: _filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search_rounded,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No other users found'
                              : 'No users found for "${_searchController.text}"',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return UserTile(
                        text: user.username,
                        subtitle: user.email,
                        onTap: () => _startChatWithUser(user),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentChatsStream() {
    final currentUserId = getCurrentUser()?.uid;
    if (currentUserId == null) {
      return const Expanded(child: Center(child: Text('Not signed in')));
    }

    return StreamBuilder<List<UserModel>>(
      stream: widget.chatServices.getUsersStream(),
      builder: (context, usersSnapshot) {
        if (!usersSnapshot.hasData) {
          return const Expanded(child: Center(child: CircularProgressIndicator()));
        }

        final allUsers = usersSnapshot.data!
            .where((user) => user.uid != currentUserId)
            .toList();

        if (allUsers.isEmpty) {
          return _buildEmptyState();
        }

        // For each user, create a stream that combines their messages and unread count
        return Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: allUsers.map((user) {
              return StreamBuilder<QuerySnapshot>(
                stream: widget.chatServices.getPrivateMessages(currentUserId, user.uid),
                builder: (context, messagesSnapshot) {
                  if (!messagesSnapshot.hasData || messagesSnapshot.data!.docs.isEmpty) {
                    return const SizedBox.shrink(); // Don't show users with no messages
                  }

                  final messages = messagesSnapshot.data!.docs;
                  final lastMessageDoc = messages.last;
                  final lastMessageData = lastMessageDoc.data() as Map<String, dynamic>;

                  return FutureBuilder<int>(
                    future: widget.chatServices.getUnreadCount(currentUserId, user.uid),
                    builder: (context, unreadSnapshot) {
                      final lastMessage = lastMessageData['message'] ?? '';
                      final lastMessageTime = (lastMessageData['timestamp'] as Timestamp).toDate();
                      final senderId = lastMessageData['senderId'];
                      final unreadCount = unreadSnapshot.data ?? 0;
                      
                      final sender = (senderId == currentUserId) ? 'You' : user.username;
                      final timestampStr = '${lastMessageTime.hour.toString().padLeft(2, '0')}:${lastMessageTime.minute.toString().padLeft(2, '0')}';

                      return UserTile(
                        text: user.username,
                        subtitle: '$sender: $lastMessage',
                        trailing: Text(
                          timestampStr,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        unreadCount: unreadCount,
                        onTap: () => _startChatWithUser(user),
                      );
                    },
                  );
                },
              );
            }).where((widget) => widget is! SizedBox).toList(),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No chats yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Start a conversation with someone',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 30),
          MainButton(
            text: 'Search Users',
            onPressed: _toggleSearch,
            width: 200,
          ),
        ],
      ),
    );
  }
}