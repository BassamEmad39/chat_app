import 'package:chat_app/core/utils/app_colors.dart';
import 'package:chat_app/features/chat/private/cubit/private_chat_state.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class MessageInputWidget extends StatelessWidget {
  final TextEditingController messageController;
  final PrivateChatState state;
  final VoidCallback onSendMessage;

  const MessageInputWidget({
    super.key,
    required this.messageController,
    required this.state,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            const Gap(8),
            CircleAvatar(
              radius: 24,
              backgroundColor: state is PrivateChatMessageSending
                  ? Colors.grey
                  : Colors.purple,
              child: IconButton(
                icon: const Icon(Icons.send, color: AppColors.whiteColor),
                onPressed: state is PrivateChatMessageSending
                    ? null
                    : onSendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}