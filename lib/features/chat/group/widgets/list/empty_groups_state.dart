import 'package:chat_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class EmptyGroupsState extends StatelessWidget {
  const EmptyGroupsState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 64,
            color: AppColors.greyColor,
          ),
          Gap(16),
          Text(
            'No groups yet',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.greyColor,
            ),
          ),
          Gap(8),
          Text(
            'Create your first group to get started!',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.greyColor,
            ),
          ),
        ],
      ),
    );
  }
}