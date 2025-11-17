import 'package:chat_app/features/chat/group/cubit/group_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class ErrorGroupsState extends StatelessWidget {
  final String errorMessage;

  const ErrorGroupsState({
    super.key,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error: $errorMessage'),
          const Gap(16),
          ElevatedButton(
            onPressed: () => context.read<GroupListCubit>().refreshGroups(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}