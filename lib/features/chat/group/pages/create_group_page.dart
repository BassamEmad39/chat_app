import 'dart:developer';
import 'package:chat_app/components/buttons/main_button.dart';
import 'package:chat_app/components/inputs/name_text_form_field.dart';
import 'package:chat_app/core/utils/app_colors.dart';
import 'package:chat_app/features/chat/group/cubit/group_list_cubit.dart';
import 'package:chat_app/features/chat/group/cubit/group_list_state.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

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
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .get();

      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      _allUsers.clear();
      _selectedUsers.clear();

      for (var doc in usersSnapshot.docs) {
        final user = UserModel.fromMap(doc.data());
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

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
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
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.blackColor.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: NameTextFormField(
                              controller: _groupNameController,
                              hintText: 'Enter group name...',
                            ),
                          ),
                          const Gap(16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$_selectedCount user${_selectedCount == 1 ? '' : 's'} selected',
                              style: const TextStyle(
                                color: AppColors.whiteColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: _allUsers.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.group_off_rounded,
                                      size: 60,
                                      color: AppColors.greyColor,
                                    ),
                                    Gap(16),
                                    Text(
                                      'No other users found',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.greyColor,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                      'Select Members',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.blackColor,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      itemCount: _allUsers.length,
                                      itemBuilder: (context, index) {
                                        final user = _allUsers[index];
                                        final isSelected =
                                            _selectedUsers[user.uid] ?? false;

                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: isSelected
                                                ? const LinearGradient(
                                                    colors: [
                                                      Color(0xFF06B6D4),
                                                      Color(0xFF8B5CF6),
                                                    ],
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                  )
                                                : null,
                                            color: isSelected
                                                ? null
                                                : Colors.grey[50],
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: AppColors.blackColor
                                                          .withValues(alpha: 0.1),
                                                      blurRadius: 6,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: isSelected
                                                  ? Colors.white
                                                  : const Color(0xFF06B6D4),
                                              child: Text(
                                                user.username[0].toUpperCase(),
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? const Color(0xFF06B6D4)
                                                      : Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              user.username,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.black87,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            subtitle: Text(
                                              user.email,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white70
                                                    : Colors.grey[600],
                                              ),
                                            ),
                                            trailing: Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.transparent,
                                                border: Border.all(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.grey,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: isSelected
                                                  ? const Icon(
                                                      Icons.check,
                                                      size: 16,
                                                      color: Color(0xFF06B6D4),
                                                    )
                                                  : null,
                                            ),
                                            onTap: () =>
                                                _toggleUserSelection(user.uid),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.blackColor.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: BlocBuilder<GroupListCubit, GroupListState>(
                        builder: (context, state) {
                          final isCreating = state is GroupListCreating;
                          
                          return MainButton(
                            text: isCreating ? 'Creating Group...' : 'Create Group',
                            onPressed: isCreating ? () {} : () => _createGroup(context),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}