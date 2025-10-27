import 'package:chat_app/features/chat/chat_services.dart';
import 'package:chat_app/features/chat/create_group_page.dart';
import 'package:chat_app/features/chat/group_chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../components/user_tile.dart';

class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  final ChatService _chatService = ChatService();

  void _startGroupChat(String groupId, String groupName) async {
    final currentUserId = _chatService.currentUserId;
    if (currentUserId == null) return;

    await _chatService.markGroupMessagesAsRead(groupId, currentUserId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupChatPage(groupId: groupId, groupName: groupName),
      ),
    );
  }

  void _createNewGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateGroupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _chatService.currentUserId;
    if (currentUserId == null) {
      return const Center(child: Text('Not signed in'));
    }

    return Stack(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: _chatService.getUserGroups(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            if (docs.isEmpty) return const Center(child: Text("No groups yet"));

            return ListView(
              padding: const EdgeInsets.all(12),
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final groupId = doc.id;
                final groupName = data['name'] ?? 'Unnamed Group';

                return StreamBuilder<QuerySnapshot>(
                  stream: _chatService.getGroupMessages(groupId),
                  builder: (context, msgSnapshot) {
                    return FutureBuilder<int>(
                      future: _chatService.getGroupUnreadCount(
                        groupId,
                        currentUserId,
                      ),
                      builder: (context, unreadSnapshot) {
                        String lastMessage = '';
                        String sender = '';
                        String timestampStr = '';
                        int unreadCount = unreadSnapshot.data ?? 0;

                        if (msgSnapshot.hasData &&
                            msgSnapshot.data!.docs.isNotEmpty) {
                          final lastDoc = msgSnapshot.data!.docs.last;
                          final lastData =
                              lastDoc.data() as Map<String, dynamic>;

                          final timestamp = (lastData['timestamp'] as Timestamp)
                              .toDate();
                          timestampStr =
                              '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

                          sender = (lastData['senderId'] == currentUserId)
                              ? 'You'
                              : lastData['senderUsername'] ?? 'Unknown';

                          lastMessage = lastData['message'] ?? '';
                        }

                        return UserTile(
                          text: groupName,
                          subtitle: lastMessage.isNotEmpty
                              ? '$sender: $lastMessage'
                              : 'No messages yet',
                          trailing: timestampStr.isNotEmpty
                              ? Text(
                                  timestampStr,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                )
                              : null,
                          unreadCount: unreadCount,
                          onTap: () => _startGroupChat(groupId, groupName),
                        );
                      },
                    );
                  },
                );
              }).toList(),
            );
          },
        ),

        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: _createNewGroup,
            backgroundColor: const Color(0xFF06B6D4),
            child: const Icon(Icons.group_add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
