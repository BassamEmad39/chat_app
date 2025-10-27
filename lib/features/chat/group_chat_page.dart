import 'package:chat_app/features/chat/chat_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  
  List<DocumentSnapshot> _messages = [];

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _markMessagesAsRead() async {
    final currentUserId = _chatService.currentUserId;
    if (currentUserId == null) return;

    await _chatService.markGroupMessagesAsRead(widget.groupId, currentUserId);
  }

  void sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await _chatService.sendGroupMessage(widget.groupId, text);
    _controller.clear();
    
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_messages.isNotEmpty) {
      _itemScrollController.scrollTo(
        index: _messages.length - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void addMember() async {
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
              final success = await _chatService.addMemberToGroup(
                widget.groupId,
                email,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? "$email added to group"
                        : "User does not exist or is already a member",
                  ),
                ),
              );
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void showMembers() {
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
                            onSelected: (value) async {
                              if (value == 'remove') {
                                await _chatService.removeMemberFromGroup(
                                  widget.groupId,
                                  member['id'],
                                );
                              } else if (value == 'makeAdmin') {
                                await _chatService.makeAdmin(
                                  widget.groupId,
                                  member['id'],
                                );
                              } else if (value == 'revokeAdmin') {
                                await _chatService.revokeAdmin(
                                  widget.groupId,
                                  member['id'],
                                );
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
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: showMembers,
          child: Text(widget.groupName),
        ),
        backgroundColor: const Color(0xFF06B6D4),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.greenAccent),
            onPressed: addMember,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: _buildMessageList(),
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    icon: const Icon(Icons.send, color: Color(0xFF06B6D4)),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    final currentUserId = _chatService.currentUserId;
    if (currentUserId == null) {
      return const Center(child: Text('Not signed in'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getGroupMessages(widget.groupId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        _messages = snapshot.data!.docs;
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        DateTime? lastDate;

        return ScrollablePositionedList.builder(
          itemScrollController: _itemScrollController,
          itemPositionsListener: _itemPositionsListener,
          padding: const EdgeInsets.all(12),
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            final doc = _messages[index];
            final data = doc.data() as Map<String, dynamic>;
            final isMe = data['senderId'] == currentUserId;
            final timestamp = (data['timestamp'] as Timestamp).toDate();

            Widget dateDivider = const SizedBox();
            if (lastDate == null || !isSameDay(lastDate!, timestamp)) {
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
      },
    );
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}