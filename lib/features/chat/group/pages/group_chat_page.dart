import 'package:chat_app/features/chat/chat_services.dart';
import 'package:chat_app/features/chat/group/cubit/group_chat_cubit.dart';
import 'package:chat_app/features/chat/group/cubit/group_chat_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add member"),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(hintText: "Enter user email"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                context.read<GroupChatCubit>().addMember(email);
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showMembers() {
    final currentUserId = _chatService.currentUserId;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("${widget.groupName} Members"),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _chatService.getGroupMembersStream(widget.groupId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();

              final members = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: members.length,
                itemBuilder: (_, index) {
                  final member = members[index];
                  final isMe = member['id'] == currentUserId;
                  final isAdmin = member['isAdmin'] as bool;
                  final canManage = member['canManage'] as bool? ?? false;

                  return ListTile(
                    title: Text(
                      member['username'],
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      isAdmin ? "Admin" : "Member",
                      style: TextStyle(
                        color: isAdmin ? Colors.blue : Colors.grey,
                      ),
                    ),
                    trailing: !isMe && canManage
                        ? PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'remove') {
                                context.read<GroupChatCubit>().removeMember(
                                  member['id'],
                                );
                              } else if (value == 'makeAdmin') {
                                context
                                    .read<GroupChatCubit>()
                                    .updateAdminStatus(member['id'], true);
                              } else if (value == 'revokeAdmin') {
                                context
                                    .read<GroupChatCubit>()
                                    .updateAdminStatus(member['id'], false);
                              }
                            },
                            itemBuilder: (context) => [
                              if (!isAdmin)
                                const PopupMenuItem(
                                  value: 'makeAdmin',
                                  child: Text('Make Admin'),
                                ),
                              if (isAdmin)
                                const PopupMenuItem(
                                  value: 'revokeAdmin',
                                  child: Text('Revoke Admin'),
                                ),
                              const PopupMenuItem(
                                value: 'remove',
                                child: Text('Remove'),
                              ),
                            ],
                          )
                        : null,
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
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
                    color: Colors.white,
                    child: _buildMessageList(state),
                  ),
                ),
                SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: "Type a message...",
                              border: InputBorder.none,
                            ),
                            onSubmitted: (value) => sendMessage(),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.send,
                            color: state is GroupChatMessageSending
                                ? Colors.grey
                                : const Color(0xFF06B6D4),
                          ),
                          onPressed: state is GroupChatMessageSending
                              ? null
                              : sendMessage,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessageList(GroupChatState state) {
    if (state is GroupChatInitial || state is GroupChatLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is GroupChatError) {
      return Center(child: Text('Error: ${state.message}'));
    }

    if (state is GroupChatLoaded && state.messages.isEmpty) {
      return const Center(
        child: Text(
          'No messages yet\nStart the conversation!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final messages = state is GroupChatLoaded
        ? state.messages
        : state is GroupChatMessageSending
        ? state.messages
        : state is GroupChatMessageSent
        ? state.messages
        : [];

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
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    Text(
                      data['message'] ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        color: isMe ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
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
