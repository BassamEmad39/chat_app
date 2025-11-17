import 'dart:developer';
import 'package:chat_app/components/user_tile.dart';
import 'package:chat_app/core/utils/app_colors.dart';
import 'package:chat_app/features/chat/chat_services.dart';
import 'package:chat_app/features/chat/private/pages/private_chat_page.dart';
import 'package:chat_app/features/chat/private/widgets/empty_state_widget.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RecentChatsListWidget extends StatefulWidget {
  final ChatService chatServices;
  final List<UserModel> allUsers;
  final Function() onToggleSearch;

  const RecentChatsListWidget({
    super.key,
    required this.chatServices,
    required this.allUsers,
    required this.onToggleSearch,
  });

  @override
  State<RecentChatsListWidget> createState() => _RecentChatsListWidgetState();
}

class _RecentChatsListWidgetState extends State<RecentChatsListWidget> {
  Future<List<Map<String, dynamic>>> _loadChatsWithLastMessages(String currentUserId) async {
    final List<Map<String, dynamic>> chats = [];

    for (final user in widget.allUsers) {
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

  @override
  Widget build(BuildContext context) {
    final currentUserId = widget.chatServices.currentUserId;
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
            return EmptyStateWidget(onToggleSearch: widget.onToggleSearch);
          }

          final chats = snapshot.data ?? [];

          final chatsWithMessages = chats.where((chat) {
            final lastMessage = chat['lastMessage'] as String?;
            return lastMessage != null && lastMessage.isNotEmpty;
          }).toList();

          if (chatsWithMessages.isEmpty) {
            return EmptyStateWidget(onToggleSearch: widget.onToggleSearch);
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

  void _startChatWithUser(UserModel user) async {
    final currentUserId = widget.chatServices.currentUserId;
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
}