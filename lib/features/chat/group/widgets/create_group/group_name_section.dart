import 'package:chat_app/components/inputs/name_text_form_field.dart';
import 'package:chat_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class GroupNameSection extends StatelessWidget {
  final TextEditingController groupNameController;
  final int selectedCount;

  const GroupNameSection({
    super.key,
    required this.groupNameController,
    required this.selectedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              controller: groupNameController,
              hintText: 'Enter group name...',
            ),
          ),
          const Gap(16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.whiteColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$selectedCount user${selectedCount == 1 ? '' : 's'} selected',
              style: const TextStyle(
                color: AppColors.whiteColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
