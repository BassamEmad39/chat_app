import 'dart:async';

import 'package:chat_app/features/chat/chat_services.dart';
import 'package:chat_app/features/chat/group/cubit/group_list_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupListCubit extends Cubit<GroupListState> {
  final ChatService _chatService;
  
  StreamSubscription<QuerySnapshot>? _groupsSubscription;
  List<Map<String, dynamic>> _currentGroups = [];

  GroupListCubit({
    required ChatService chatService,
  })  : _chatService = chatService,
        super(GroupListInitial()) {
    _loadGroups();
  }

  void _loadGroups() {
    emit(GroupListLoading());
    
    _groupsSubscription = _chatService.getUserGroups().listen(
      (QuerySnapshot snapshot) {
        _currentGroups = _processGroups(snapshot.docs);
        emit(GroupListLoaded(_currentGroups));
      },
      onError: (error) {
        emit(GroupListError('Failed to load groups: $error'));
      },
    );
  }

  List<Map<String, dynamic>> _processGroups(List<QueryDocumentSnapshot> docs) {
    final currentUserId = _chatService.currentUserId;
    if (currentUserId == null) return [];

    List<Map<String, dynamic>> groups = [];

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final groupId = doc.id;
      final groupName = data['name'] ?? 'Unnamed Group';

      groups.add({
        'id': groupId,
        'name': groupName,
      });
    }

    return groups;
  }

  Future<void> createGroup(String name, List<String> memberIds) async {
    if (name.trim().isEmpty) {
      emit(GroupListError('Group name cannot be empty'));
      return;
    }

    if (memberIds.isEmpty) {
      emit(GroupListError('Please select at least one member'));
      return;
    }

    emit(GroupListCreating(_currentGroups));

    try {
      await _chatService.createGroup(name, memberIds);
    } catch (error) {
      emit(GroupListError('Failed to create group: $error'));
    }
  }

  Future<void> refreshGroups() async {
    emit(GroupListLoading());
  }

  @override
  Future<void> close() {
    _groupsSubscription?.cancel();
    return super.close();
  }
}