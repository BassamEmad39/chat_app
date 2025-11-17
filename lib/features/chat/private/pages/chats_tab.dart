import 'dart:async';
import 'dart:developer';
import 'package:chat_app/components/buttons/main_button.dart';
import 'package:chat_app/components/inputs/name_text_form_field.dart';
import 'package:chat_app/components/user_tile.dart';
import 'package:chat_app/core/utils/app_colors.dart';
import 'package:chat_app/features/chat/chat_services.dart';
import 'package:chat_app/features/chat/private/pages/private_chat_page.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

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
  
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _loadAllUsers();
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
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
                  color: AppColors.blackColor,
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
          _buildRecentChatsList(), 
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
                color: AppColors.greyColor,
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
                          color: AppColors.greyColor,
                        ),
                        const Gap(16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No other users found'
                              : 'No users found for "${_searchController.text}"',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.greyColor,
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

  Widget _buildRecentChatsList() {
    final currentUserId = getCurrentUser()?.uid;
    if (currentUserId == null) {
      return const Expanded(child: Center(child: Text('Not signed in')));
    }

    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadChatsWithLastMessages(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            log('Error loading chats: ${snapshot.error}');
            return _buildEmptyState();
          }

          final chats = snapshot.data ?? [];

          final chatsWithMessages = chats.where((chat) {
            final lastMessage = chat['lastMessage'] as String?;
            return lastMessage != null && lastMessage.isNotEmpty;
          }).toList();

          if (chatsWithMessages.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: chatsWithMessages.length,
            itemBuilder: (context, index) {
              final chat = chatsWithMessages[index];
              final user = chat['user'] as UserModel;
              final lastMessage = chat['lastMessage'] as String;
              final timestampStr = chat['timestampStr'] as String;
              final sender = chat['sender'] as String;
              final unreadCount = chat['unreadCount'] as int;

              return UserTile(
                text: user.username,
                subtitle: '$sender: $lastMessage',
                trailing: Text(
                  timestampStr,
                  style: const TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 12,
                  ),
                ),
                unreadCount: unreadCount,
                onTap: () => _startChatWithUser(user),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadChatsWithLastMessages(String currentUserId) async {
    final List<Map<String, dynamic>> chats = [];

    for (final user in _allUsers) {
      try {
        final messagesSnapshot = await widget.chatServices
            .getPrivateMessages(currentUserId, user.uid)
            .first;

        if (messagesSnapshot.docs.isNotEmpty) {
          final lastMessageDoc = messagesSnapshot.docs.last;
          final lastMessageData = lastMessageDoc.data() as Map<String, dynamic>;

          final lastMessage = lastMessageData['message'] ?? '';
          final lastMessageTime = (lastMessageData['timestamp'] as Timestamp).toDate();
          final senderId = lastMessageData['senderId'];
          final sender = (senderId == currentUserId) ? 'You' : user.username;
          final timestampStr = '${lastMessageTime.hour.toString().padLeft(2, '0')}:${lastMessageTime.minute.toString().padLeft(2, '0')}';

          final unreadCount = await widget.chatServices.getUnreadCount(currentUserId, user.uid);

          chats.add({
            'user': user,
            'lastMessage': lastMessage,
            'lastMessageTime': lastMessageTime,
            'sender': sender,
            'timestampStr': timestampStr,
            'unreadCount': unreadCount,
          });
        }
      } catch (e) {
        log('Error loading messages for user ${user.uid}: $e');
      }
    }

    chats.sort((a, b) {
      final timeA = a['lastMessageTime'] as DateTime;
      final timeB = b['lastMessageTime'] as DateTime;
      return timeB.compareTo(timeA);
    });

    return chats;
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 80,
            color: AppColors.greyColor,
          ),
          const Gap(20),
          Text(
            'No chats yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.greyColor,
            ),
          ),
          const Gap(10),
          Text(
            'Start a conversation with someone',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.greyColor,
            ),
          ),
          const Gap(30),
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