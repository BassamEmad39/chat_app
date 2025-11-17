import 'package:chat_app/components/user_tile.dart';
import 'package:chat_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class GroupListItemWidget extends StatelessWidget {
  final String groupName;
  final String lastMessage;
  final String sender;
  final String timestampStr;
  final int unreadCount;
  final VoidCallback onTap;

  const GroupListItemWidget({
    super.key,
    required this.groupName,
    required this.lastMessage,
    required this.sender,
    required this.timestampStr,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return UserTile(
      text: groupName,
      subtitle: lastMessage.isNotEmpty
          ? '$sender: $lastMessage'
          : 'No messages yet',
      trailing: timestampStr.isNotEmpty
          ? Text(
              timestampStr,
              style: const TextStyle(
                color: AppColors.whiteColor,
                fontSize: 12,
              ),
            )
          : null,
      unreadCount: unreadCount,
      onTap: onTap,
    );
  }
}