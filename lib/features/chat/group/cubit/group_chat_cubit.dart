import 'dart:async';
import 'dart:developer';

import 'package:chat_app/features/chat/chat_services.dart';
import 'package:chat_app/features/chat/group/cubit/group_chat_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupChatCubit extends Cubit<GroupChatState> {
  final ChatService _chatService;
  final String groupId;
  
  StreamSubscription<QuerySnapshot>? _messagesSubscription;
  List<DocumentSnapshot> _currentMessages = [];

  GroupChatCubit({
    required ChatService chatService,
    required this.groupId,
  })  : _chatService = chatService,
        super(GroupChatInitial()) {
    _loadMessages();
  }

  void _loadMessages() {
    emit(GroupChatLoading());
    
    _messagesSubscription = _chatService.getGroupMessages(groupId).listen(
      (QuerySnapshot snapshot) {
        _currentMessages = snapshot.docs;
        
        final currentUserId = _chatService.currentUserId;
        if (currentUserId != null) {
          _checkUnreadMessages(currentUserId);
        } else {
          emit(GroupChatLoaded(
            messages: _currentMessages,
            hasUnreadMessages: false,
          ));
        }
      },
      onError: (error) {
        emit(GroupChatError('Failed to load messages: $error'));
      },
    );
  }

  void _checkUnreadMessages(String currentUserId) async {
    try {
      final unreadCount = await _chatService.getGroupUnreadCount(
        groupId, 
        currentUserId,
      );
      
      emit(GroupChatLoaded(
        messages: _currentMessages,
        hasUnreadMessages: unreadCount > 0,
      ));
    } catch (error) {
      emit(GroupChatLoaded(
        messages: _currentMessages,
        hasUnreadMessages: false,
      ));
    }
  }

  Future<void> sendMessage(String messageText) async {
    if (messageText.trim().isEmpty) return;
    
    emit(GroupChatMessageSending(_currentMessages));
    
    try {
      await _chatService.sendGroupMessage(groupId, messageText.trim());
    } catch (error) {
      emit(GroupChatError('Failed to send message: $error'));
    }
  }

  Future<void> markMessagesAsRead() async {
    final currentUserId = _chatService.currentUserId;
    if (currentUserId == null) return;
    
    try {
      await _chatService.markGroupMessagesAsRead(groupId, currentUserId);
    } catch (error) {
      log('Error marking messages as read: $error');
    }
  }

  Future<void> addMember(String email) async {
    try {
      final success = await _chatService.addMemberToGroup(groupId, email);
      
      if (!success) {
        emit(GroupChatError('User does not exist or is already a member'));
      }
    } catch (error) {
      emit(GroupChatError('Failed to add member: $error'));
    }
  }

  Future<void> removeMember(String memberId) async {
    try {
      await _chatService.removeMemberFromGroup(groupId, memberId);
    } catch (error) {
      emit(GroupChatError('Failed to remove member: $error'));
    }
  }

  Future<void> updateAdminStatus(String memberId, bool makeAdmin) async {
    try {
      if (makeAdmin) {
        await _chatService.makeAdmin(groupId, memberId);
      } else {
        await _chatService.revokeAdmin(groupId, memberId);
      }
    } catch (error) {
      emit(GroupChatError('Failed to update admin status: $error'));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}