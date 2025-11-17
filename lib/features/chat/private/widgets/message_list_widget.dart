import 'package:chat_app/core/utils/app_colors.dart';
import 'package:chat_app/features/chat/chat_services.dart';
import 'package:chat_app/features/chat/private/cubit/private_chat_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class MessageListWidget extends StatelessWidget {
  final PrivateChatState state;
  final ChatService chatService;
  final ScrollController scrollController;
  final List<DocumentSnapshot<Object?>> messages;
  

  const MessageListWidget({
    super.key,
    required this.state,
    required this.chatService,
    required this.scrollController,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    if (state is PrivateChatInitial || state is PrivateChatLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PrivateChatError) {
      return Center(
        child: Text('Error: ${(state as PrivateChatError).message}'),
      );
    }

    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'No messages yet\nStart the conversation!',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.greyColor),
        ),
      );
    }

    DateTime? lastDate;

    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.all(12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final reversedIndex = messages.length - 1 - index;
        final doc = messages[reversedIndex];
        // ignore: unnecessary_cast
        final data = doc.data() as Map<String, dynamic>;
        final isMe = data['senderId'] == chatService.currentUserId;
        final timestamp = (data['timestamp'] as Timestamp).toDate();

        Widget dateDivider = const SizedBox();
        if (lastDate == null || !_isSameDay(lastDate!, timestamp)) {
          lastDate = timestamp;
          dateDivider = Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                DateFormat('yyyy/MM/dd').format(timestamp),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            dateDivider,
            Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: isMe
                      ? const LinearGradient(
                          colors: [Colors.cyan, Colors.purple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isMe ? null : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (!isMe)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          data['senderUsername'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blackColor,
                          ),
                        ),
                      ),
                    Text(
                      data['message'] ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        color: isMe
                            ? AppColors.whiteColor
                            : AppColors.blackColor,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      DateFormat('HH:mm').format(timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe ? Colors.white70 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
