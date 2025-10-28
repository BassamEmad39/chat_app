import 'dart:async';
import 'dart:developer';

import 'package:chat_app/features/chat/chat_services.dart';
import 'package:chat_app/features/chat/private/cubit/private_chat_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PrivateChatCubit extends Cubit<PrivateChatState> {
  final ChatService _chatService;
  final String receiverId;
  final String currentUserId;
  
  StreamSubscription<QuerySnapshot>? _messagesSubscription;
  List<DocumentSnapshot> _currentMessages = [];

  PrivateChatCubit({
    required ChatService chatService,
    required this.receiverId,
    required this.currentUserId,
  })  : _chatService = chatService,
        super(PrivateChatInitial()) {
    _loadMessages();
  }

  void _loadMessages() {
    emit(PrivateChatLoading());
    
    _messagesSubscription = _chatService
        .getPrivateMessages(currentUserId, receiverId)
        .listen(
      (QuerySnapshot snapshot) {
        _currentMessages = snapshot.docs;
        
        _checkUnreadMessages();
      },
      onError: (error) {
        emit(PrivateChatError('Failed to load messages: $error'));
      },
    );
  }

  void _checkUnreadMessages() async {
    try {
      final unreadCount = await _chatService.getUnreadCount(
        currentUserId, 
        receiverId,
      );
      
      emit(PrivateChatLoaded(
        messages: _currentMessages,
        hasUnreadMessages: unreadCount > 0,
      ));
    } catch (error) {
      emit(PrivateChatLoaded(
        messages: _currentMessages,
        hasUnreadMessages: false,
      ));
    }
  }

  Future<void> sendMessage(String messageText) async {
    if (messageText.trim().isEmpty) return;
    
    emit(PrivateChatMessageSending(_currentMessages));
    
    try {
      await _chatService.sendPrivateMessage(receiverId, messageText.trim());
    } catch (error) {
      emit(PrivateChatError('Failed to send message: $error'));
    }
  }

  Future<void> markMessagesAsRead() async {
    try {
      List<String> ids = [currentUserId, receiverId]..sort();
      String chatRoomId = ids.join('_');
      
      await _chatService.markMessagesAsRead(chatRoomId, currentUserId);
    } catch (error) {
      log('Error marking messages as read: $error');
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}