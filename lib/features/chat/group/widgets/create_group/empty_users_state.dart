import 'package:chat_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class EmptyUsersState extends StatelessWidget {
  const EmptyUsersState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
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
    );
  }
}