import 'package:chat_app/core/utils/app_colors.dart';
import 'package:chat_app/features/chat/group/cubit/group_chat_state.dart';
import 'package:flutter/material.dart';

class GroupMessageInputWidget extends StatelessWidget {
  final TextEditingController messageController;
  final GroupChatState state;
  final VoidCallback onSendMessage;

  const GroupMessageInputWidget({
    super.key,
    required this.messageController,
    required this.state,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        color: AppColors.whiteColor,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                ),
                onSubmitted: (value) => onSendMessage(),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.send,
                color: state is GroupChatMessageSending
                    ? Colors.grey
                    : const Color(0xFF06B6D4),
              ),
              onPressed: state is GroupChatMessageSending ? null : onSendMessage,
            ),
          ],
        ),
      ),
    );
  }
}