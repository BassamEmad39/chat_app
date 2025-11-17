import 'dart:async';
import 'package:chat_app/features/chat/chat_services.dart';
import 'package:chat_app/features/chat/group/widgets/list/group_list_item_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> groups;
  final ChatService chatService;
  final Function(String, String) onGroupTap;

  const GroupListWidget({
    super.key,
    required this.groups,
    required this.chatService,
    required this.onGroupTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = chatService.currentUserId;
    if (currentUserId == null) {
      return const Center(child: Text('Not signed in'));
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getGroupsWithLatestMessages(groups, currentUserId),
      builder: (context, sortedGroupsSnapshot) {
        if (!sortedGroupsSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final sortedGroups = sortedGroupsSnapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: sortedGroups.length,
          itemBuilder: (context, index) {
            final group = sortedGroups[index];
            final groupId = group['id'] as String;
            final groupName = group['name'] as String;
            final lastMessage = group['lastMessage'] as String;
            final sender = group['sender'] as String;
            final timestampStr = group['timestampStr'] as String;
            final unreadCount = group['unreadCount'] as int;

            return GroupListItemWidget(
              groupName: groupName,
              lastMessage: lastMessage,
              sender: sender,
              timestampStr: timestampStr,
              unreadCount: unreadCount,
              onTap: () => onGroupTap(groupId, groupName),
            );
          },
        );
      },
    );
  }

  Stream<List<Map<String, dynamic>>> _getGroupsWithLatestMessages(
      List<Map<String, dynamic>> groups, String currentUserId) {
    final Map<String, Map<String, dynamic>> groupDataMap = {};

    final StreamController<List<Map<String, dynamic>>> controller =
        StreamController<List<Map<String, dynamic>>>();

    for (final group in groups) {
      final groupId = group['id'] as String;

      chatService.getGroupMessages(groupId).listen((snapshot) async {
        String lastMessage = '';
        String sender = '';
        String timestampStr = '';
        DateTime lastMessageTime = DateTime(0);

        if (snapshot.docs.isNotEmpty) {
          final lastDoc = snapshot.docs.last;
          final lastData = lastDoc.data() as Map<String, dynamic>;

          lastMessageTime = (lastData['timestamp'] as Timestamp).toDate();
          timestampStr = '${lastMessageTime.hour.toString().padLeft(2, '0')}:${lastMessageTime.minute.toString().padLeft(2, '0')}';

          sender = (lastData['senderId'] == currentUserId)
              ? 'You'
              : lastData['senderUsername'] ?? 'Unknown';

          lastMessage = lastData['message'] ?? '';
        }

        final unreadCount = await chatService.getGroupUnreadCount(groupId, currentUserId);

        groupDataMap[groupId] = {
          ...group,
          'lastMessage': lastMessage,
          'sender': sender,
          'timestampStr': timestampStr,
          'unreadCount': unreadCount,
          'lastMessageTime': lastMessageTime,
        };

        final sortedGroups = groupDataMap.values.toList()
          ..sort((a, b) {
            final timeA = a['lastMessageTime'] as DateTime;
            final timeB = b['lastMessageTime'] as DateTime;
            return timeB.compareTo(timeA);
          });

        controller.add(sortedGroups);
      });
    }

    return controller.stream;
  }
}