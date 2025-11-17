import 'package:chat_app/core/utils/app_colors.dart';
import 'package:chat_app/features/chat/chat_services.dart';
import 'package:chat_app/features/chat/group/cubit/group_chat_cubit.dart';
import 'package:chat_app/features/chat/group/cubit/group_chat_state.dart';
import 'package:chat_app/features/chat/group/widgets/chat/add_member_dialog.dart';
import 'package:chat_app/features/chat/group/widgets/chat/group_members_dialog.dart';
import 'package:chat_app/features/chat/group/widgets/chat/group_message_input_widget.dart';
import 'package:chat_app/features/chat/group/widgets/chat/group_message_list_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
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

  void _addMember() {
    showDialog(
      context: context,
      builder: (_) => const AddMemberDialog(),
    );
  }

  void _showMembers() {
    showDialog(
      context: context,
      builder: (_) => GroupMembersDialog(
        groupId: widget.groupId,
        groupName: widget.groupName,
        chatService: _chatService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GroupChatCubit(chatService: _chatService, groupId: widget.groupId),
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: _showMembers,
            child: Text(widget.groupName),
          ),
          backgroundColor: const Color(0xFF06B6D4),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add, color: Colors.greenAccent),
              onPressed: _addMember,
            ),
          ],
        ),
        body: BlocConsumer<GroupChatCubit, GroupChatState>(
          listener: (context, state) {
            if (state is GroupChatError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }

            if (state is GroupChatLoaded || state is GroupChatMessageSent) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
            }
          },
          builder: (context, state) {
            void sendMessage() {
              final text = _controller.text.trim();
              if (text.isEmpty) return;

              context.read<GroupChatCubit>().sendMessage(text);
              _controller.clear();
            }

            return Column(
              children: [
                Expanded(
                  child: Container(
                    color: AppColors.whiteColor,
                    child: GroupMessageListWidget(
                      state: state,
                      chatService: _chatService,
                      scrollController: _scrollController,
                      messages: _getMessagesFromState(state),
                    ),
                  ),
                ),
                GroupMessageInputWidget(
                  messageController: _controller,
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

  List<DocumentSnapshot> _getMessagesFromState(GroupChatState state) {
    if (state is GroupChatLoaded) {
      return state.messages;
    } else if (state is GroupChatMessageSending) {
      return state.messages;
    } else if (state is GroupChatMessageSent) {
      return state.messages;
    }
    return [];
  }
}