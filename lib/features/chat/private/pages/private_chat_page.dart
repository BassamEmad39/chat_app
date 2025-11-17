import 'package:chat_app/core/utils/app_colors.dart';
import 'package:chat_app/features/chat/chat_services.dart';
import 'package:chat_app/features/chat/private/cubit/private_chat_cubit.dart';
import 'package:chat_app/features/chat/private/cubit/private_chat_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class PrivateChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;
  final String receiverUsername;

  const PrivateChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
    required this.receiverUsername,
  });

  @override
  State<PrivateChatPage> createState() => _PrivateChatPageState();
}

class _PrivateChatPageState extends State<PrivateChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _chatService.currentUserId;

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.receiverUsername)),
        body: const Center(child: Text('Not signed in')),
      );
    }

    return BlocProvider(
      create: (context) => PrivateChatCubit(
        chatService: _chatService,
        receiverId: widget.receiverID,
        currentUserId: currentUserId,
      ),
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          title: Text(widget.receiverUsername),
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: AppColors.mainGradient),
          ),
        ),
        body: BlocConsumer<PrivateChatCubit, PrivateChatState>(
          listener: (context, state) {
            if (state is PrivateChatError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }

            if (state is PrivateChatLoaded || state is PrivateChatMessageSent) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
            }

            if (state is PrivateChatLoaded) {
              context.read<PrivateChatCubit>().markMessagesAsRead();
            }
          },
          builder: (context, state) {
            void sendMessage() {
              final text = _messageController.text.trim();
              if (text.isEmpty) return;

              context.read<PrivateChatCubit>().sendMessage(text);
              _messageController.clear();
            }

            return Column(
              children: [
                Expanded(child: _buildMessageList(state)),
                _buildInputField(state, sendMessage),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessageList(PrivateChatState state) {
    if (state is PrivateChatInitial || state is PrivateChatLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PrivateChatError) {
      return Center(child: Text('Error: ${state.message}'));
    }

    final messages = state.messages;

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
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.all(12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final reversedIndex = messages.length - 1 - index;
        final doc = messages[reversedIndex];
        final data = doc.data() as Map<String, dynamic>;
        final isMe = data['senderId'] == _chatService.currentUserId;
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

  Widget _buildInputField(PrivateChatState state, VoidCallback sendMessage) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: AppColors.whiteColor,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                ),
                onSubmitted: (value) => sendMessage(),
              ),
            ),
            Gap(8),
            CircleAvatar(
              radius: 24,
              backgroundColor: state is PrivateChatMessageSending
                  ? Colors.grey
                  : Colors.purple,
              child: IconButton(
                icon: const Icon(Icons.send, color: AppColors.whiteColor),
                onPressed: state is PrivateChatMessageSending
                    ? null
                    : sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
