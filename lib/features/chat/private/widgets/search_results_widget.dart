import 'package:chat_app/components/user_tile.dart';
import 'package:chat_app/core/utils/app_colors.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SearchResultsWidget extends StatelessWidget {
  final List<UserModel> filteredUsers;
  final TextEditingController searchController;
  final Function(UserModel) onUserTap;

  const SearchResultsWidget({
    super.key,
    required this.filteredUsers,
    required this.searchController,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              searchController.text.isEmpty
                  ? 'All users (${filteredUsers.length})'
                  : 'Found ${filteredUsers.length} user${filteredUsers.length == 1 ? '' : 's'}',
              style: TextStyle(
                color: AppColors.greyColor,
                fontSize: 14,
              ),
            ),
          ),
          
          Expanded(
            child: filteredUsers.isEmpty
                ? _buildEmptySearchState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return UserTile(
                        text: user.username,
                        subtitle: user.email,
                        onTap: () => onUserTap(user),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search_rounded,
            size: 60,
            color: AppColors.greyColor,
          ),
          const Gap(16),
          Text(
            searchController.text.isEmpty
                ? 'No other users found'
                : 'No users found for "${searchController.text}"',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.greyColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}