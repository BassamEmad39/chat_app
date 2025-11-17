import 'package:chat_app/core/utils/app_colors.dart';
import 'package:chat_app/features/chat/chat_services.dart';
import 'package:chat_app/features/chat/private/cubit/private_chat_cubit.dart';
import 'package:chat_app/features/chat/private/cubit/private_chat_state.dart';
import 'package:chat_app/features/chat/private/widgets/message_input_widget.dart';
import 'package:chat_app/features/chat/private/widgets/message_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
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
                Expanded(
                  child: MessageListWidget(
                    state: state,
                    chatService: _chatService,
                    scrollController: _scrollController,
                    messages: state.messages,
                  ),
                ),
                MessageInputWidget(
                  messageController: _messageController,
                  state: state,
                  onSendMessage: sendMessage,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}