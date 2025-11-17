import 'package:chat_app/components/buttons/main_button.dart';
import 'package:chat_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class EmptyStateWidget extends StatelessWidget {
  final Function() onToggleSearch;

  const EmptyStateWidget({
    super.key,
    required this.onToggleSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 80,
            color: AppColors.greyColor,
          ),
          const Gap(20),
          Text(
            'No chats yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.greyColor,
            ),
          ),
          const Gap(10),
          Text(
            'Start a conversation with someone',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.greyColor,
            ),
          ),
          const Gap(30),
          MainButton(
            text: 'Search Users',
            onPressed: onToggleSearch,
            width: 200,
          ),
        ],
      ),
    );
  }
}