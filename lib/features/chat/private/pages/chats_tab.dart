import 'dart:async';
import 'dart:developer';
import 'package:chat_app/components/inputs/name_text_form_field.dart';
import 'package:chat_app/core/utils/app_colors.dart';
import 'package:chat_app/features/chat/chat_services.dart';
import 'package:chat_app/features/chat/private/pages/private_chat_page.dart';
import 'package:chat_app/features/chat/private/widgets/recent_chats_list_widget.dart';
import 'package:chat_app/features/chat/private/widgets/search_results_widget.dart';
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
        _buildHeader(),
        if (_showSearch) ...[
          _buildSearchField(),
          SearchResultsWidget(
            filteredUsers: _filteredUsers,
            searchController: _searchController,
            onUserTap: _startChatWithUser,
          ),
        ] else ...[
          RecentChatsListWidget(
            chatServices: widget.chatServices,
            allUsers: _allUsers,
            onToggleSearch: _toggleSearch,
          ),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
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
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: NameTextFormField(
        controller: _searchController,
        hintText: 'Search by username or email...',
        onChanged: _searchUsers,
      ),
    );
  }
}