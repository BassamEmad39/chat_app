import 'package:chat_app/core/utils/app_colors.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:flutter/material.dart';

import 'empty_users_state.dart';
import 'user_list_item.dart';

class UserSelectionList extends StatelessWidget {
  final List<UserModel> allUsers;
  final Map<String, bool> selectedUsers;
  final Function(String) onUserTap;

  const UserSelectionList({
    super.key,
    required this.allUsers,
    required this.selectedUsers,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: allUsers.isEmpty
            ? const EmptyUsersState()
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: allUsers.length,
                      itemBuilder: (context, index) {
                        final user = allUsers[index];
                        final isSelected = selectedUsers[user.uid] ?? false;

                        return UserListItem(
                          user: user,
                          isSelected: isSelected,
                          onTap: () => onUserTap(user.uid),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}