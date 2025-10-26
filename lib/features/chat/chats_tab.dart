import 'package:chat_app/components/user_tile.dart';
import 'package:chat_app/features/chat/chat_services.dart';
import 'package:chat_app/features/chat/private_chat_page.dart';
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

  @override
  Widget build(BuildContext context) {
    final currentUserId = getCurrentUser()?.uid;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: widget.chatServices.getUsersStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: users.map<Widget>((userData) {
            if (userData['uid'] == currentUserId) {
              return const SizedBox.shrink();
            }

            return FutureBuilder<QuerySnapshot>(
              future: widget.chatServices
                  .getPrivateMessages(currentUserId!, userData['uid'])
                  .first,
              builder: (context, msgSnapshot) {
                String lastMessage = '';
                String sender = '';
                String timestampStr = '';
                int unread = 0;

                if (msgSnapshot.hasData && msgSnapshot.data!.docs.isNotEmpty) {
                  final lastDoc = msgSnapshot.data!.docs.last;
                  final data = lastDoc.data() as Map<String, dynamic>;

                  final timestamp = (data['timestamp'] as Timestamp).toDate();
                  timestampStr =
                      '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

                  sender = (data['senderId'] == currentUserId)
                      ? 'You'
                      : data['senderEmail'] ?? '';
                  lastMessage = data['message'] ?? '';
                  unread = (data['senderId'] != currentUserId) ? 1 : 0;
                }

                return UserTile(
                  text: userData['email'],
                  subtitle: lastMessage.isNotEmpty
                      ? '$sender: $lastMessage'
                      : null,
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
                        builder: (_) => PrivateChatPage(
                          recieverEmail: userData['email'],
                          recieverID: userData['uid'],
                        ),
                      ),
                    ).then(
                      (_) => setState(() {}),
                    ); // Refresh last message on return
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
