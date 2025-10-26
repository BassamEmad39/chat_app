import 'package:chat_app/features/chat/chat_services.dart';
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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

            return FutureBuilder<QuerySnapshot>(
              future: _chatService.getGroupMessages(groupId).first,
              builder: (context, msgSnapshot) {
                String lastMessage = '';
                String sender = '';
                String timestampStr = '';
                int unread = 0;

                if (msgSnapshot.hasData && msgSnapshot.data!.docs.isNotEmpty) {
                  final lastDoc = msgSnapshot.data!.docs.last;
                  final lastData = lastDoc.data() as Map<String, dynamic>;

                  final timestamp = (lastData['timestamp'] as Timestamp)
                      .toDate();
                  timestampStr =
                      '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

                  sender = (lastData['senderId'] == _chatService.currentUserId)
                      ? 'You'
                      : lastData['senderUsername'] ?? 'Unknown';

                  lastMessage = lastData['message'] ?? '';
                  unread = (lastData['senderId'] != _chatService.currentUserId)
                      ? 1
                      : 0;
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
                  unreadCount: unread,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupChatPage(
                          groupId: groupId,
                          groupName: groupName,
                        ),
                      ),
                    ).then(
                      (_) => setState(() {}),
                    ); // Refresh last message after returning
                  },
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}