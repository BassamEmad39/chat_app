import 'package:chat_app/core/utils/app_colors.dart' show AppColors;
import 'package:chat_app/features/chat/chat_services.dart';
import 'package:chat_app/features/chat/group/pages/create_group_page.dart';
import 'package:chat_app/features/chat/group/cubit/group_list_cubit.dart';
import 'package:chat_app/features/chat/group/cubit/group_list_state.dart';
import 'package:chat_app/features/chat/group/pages/group_chat_page.dart';
import 'package:chat_app/features/chat/group/widgets/list/empty_groups_state.dart';
import 'package:chat_app/features/chat/group/widgets/list/error_groups_state.dart';
import 'package:chat_app/features/chat/group/widgets/list/group_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  final ChatService _chatService = ChatService();
  late final GroupListCubit _groupListCubit;

  @override
  void initState() {
    super.initState();
    _groupListCubit = GroupListCubit(chatService: _chatService);
  }

  @override
  void dispose() {
    _groupListCubit.close();
    super.dispose();
  }

  void _startGroupChat(String groupId, String groupName) async {
    final currentUserId = _chatService.currentUserId;
    if (currentUserId == null) return;

    await _chatService.markGroupMessagesAsRead(groupId, currentUserId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupChatPage(groupId: groupId, groupName: groupName),
      ),
    );
  }

  void _createNewGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _groupListCubit,
          child: CreateGroupPage(chatService: _chatService,),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _chatService.currentUserId;
    if (currentUserId == null) {
      return const Center(child: Text('Not signed in'));
    }

    return BlocBuilder<GroupListCubit, GroupListState>(
      bloc: _groupListCubit,
      builder: (context, state) {
        return Stack(
          children: [
            _buildStateContent(state, currentUserId),
            _buildFloatingActionButton(),
          ],
        );
      },
    );
  }

  Widget _buildStateContent(GroupListState state, String currentUserId) {
    if (state is GroupListInitial || state is GroupListLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is GroupListError) {
      return ErrorGroupsState(errorMessage: state.message);
    }

    if (state is GroupListLoaded && state.groups.isEmpty) {
      return const EmptyGroupsState();
    }

    final groups = _getGroupsFromState(state);
    return GroupListWidget(
      groups: groups,
      chatService: _chatService,
      onGroupTap: _startGroupChat,
    );
  }

  List<Map<String, dynamic>> _getGroupsFromState(GroupListState state) {
    if (state is GroupListLoaded) {
      return state.groups;
    } else if (state is GroupListCreating) {
      return state.groups;
    } else if (state is GroupListCreated) {
      return state.groups;
    }
    return [];
  }

  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(
        onPressed: _createNewGroup,
        backgroundColor: const Color(0xFF06B6D4),
        child: const Icon(Icons.group_add, color: AppColors.whiteColor),
      ),
    );
  }
}