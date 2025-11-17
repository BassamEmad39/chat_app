import 'dart:developer';
import 'package:chat_app/core/utils/app_colors.dart';
import 'package:chat_app/features/chat/chat_services.dart';
import 'package:chat_app/features/chat/group/cubit/group_list_cubit.dart';
import 'package:chat_app/features/chat/group/cubit/group_list_state.dart';
import 'package:chat_app/features/chat/group/widgets/create_group/create_group_button.dart';
import 'package:chat_app/features/chat/group/widgets/create_group/group_name_section.dart';
import 'package:chat_app/features/chat/group/widgets/create_group/user_selection_list.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateGroupPage extends StatefulWidget {
  final ChatService chatService;
  
  const CreateGroupPage({
    super.key,
    required this.chatService,
  });

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final List<UserModel> _allUsers = [];
  final Map<String, bool> _selectedUsers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  void _loadUsers() async {
    try {
      final currentUserId = widget.chatService.currentUserId;
      if (currentUserId == null) return;

      final usersStream = widget.chatService.getUsersStream();
      final usersSnapshot = await usersStream.first;

      _allUsers.clear();
      _selectedUsers.clear();

      for (final user in usersSnapshot) {
        if (user.uid != currentUserId) {
          _allUsers.add(user);
          _selectedUsers[user.uid] = false;
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      log('Error loading users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _createGroup(BuildContext context) {
    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty) {
      _showError('Please enter a group name');
      return;
    }

    final selectedUserIds = _selectedUsers.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedUserIds.isEmpty) {
      _showError('Please select at least one member');
      return;
    }

    final currentUserId = widget.chatService.currentUserId;
    if (currentUserId == null) return;

    final allMembers = [...selectedUserIds, currentUserId];
    
    context.read<GroupListCubit>().createGroup(groupName, allMembers);
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.redColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      _selectedUsers[userId] = !(_selectedUsers[userId] ?? false);
    });
  }

  int get _selectedCount {
    return _selectedUsers.values.where((isSelected) => isSelected).length;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupListCubit, GroupListState>(
      listener: (context, state) {
        if (state is GroupListError) {
          _showError(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.greyColor,
        appBar: AppBar(
          title: const Text(
            'Create New Group',
            style: TextStyle(color: AppColors.whiteColor, fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    GroupNameSection(
                      groupNameController: _groupNameController,
                      selectedCount: _selectedCount,
                    ),
                    UserSelectionList(
                      allUsers: _allUsers,
                      selectedUsers: _selectedUsers,
                      onUserTap: _toggleUserSelection,
                    ),
                    CreateGroupButton(
                      onCreateGroup: () => _createGroup(context),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}