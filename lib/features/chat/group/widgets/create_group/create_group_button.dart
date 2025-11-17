import 'package:chat_app/components/buttons/main_button.dart';
import 'package:chat_app/core/utils/app_colors.dart';
import 'package:chat_app/features/chat/group/cubit/group_list_cubit.dart';
import 'package:chat_app/features/chat/group/cubit/group_list_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateGroupButton extends StatelessWidget {
  final VoidCallback onCreateGroup;

  const CreateGroupButton({super.key, required this.onCreateGroup});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BlocBuilder<GroupListCubit, GroupListState>(
        builder: (context, state) {
          final isCreating = state is GroupListCreating;

          if (isCreating) {
            return MainButton(
              text: 'Creating Group...',
              onPressed: () {},
              bgColor: Colors.grey,
            );
          } else {
            return MainButton(text: 'Create Group', onPressed: onCreateGroup);
          }
        },
      ),
    );
  }
}
