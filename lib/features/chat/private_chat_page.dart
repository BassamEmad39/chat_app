import 'package:chat_app/features/chat/chat_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
    _messageController.dispose();
    super.dispose();
  }

  void _markMessagesAsRead() async {
    final currentUserId = _chatService.currentUserId;
    if (currentUserId == null) return;

    List<String> ids = [currentUserId, widget.receiverID]..sort();
    String chatRoomId = ids.join('_');

    await _chatService.markMessagesAsRead(chatRoomId, currentUserId);
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    await _chatService.sendPrivateMessage(widget.receiverID, text);
    _messageController.clear();
    
    // Scroll to bottom after sending
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.receiverUsername),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.cyan, Colors.purple],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildInputField(),
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
      stream: _chatService.getPrivateMessages(currentUserId, widget.receiverID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No messages yet\nStart the conversation!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        _messages = snapshot.data!.docs;
        
        // Scroll to bottom when new messages load
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

  Widget _buildInputField() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                ),
                onSubmitted: (value) => _sendMessage(),
              ),
            ),
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.purple,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}