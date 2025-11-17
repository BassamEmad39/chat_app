import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/features/chat/group/cubit/group_chat_cubit.dart';

class AddMemberDialog extends StatelessWidget {
  const AddMemberDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    return AlertDialog(
      title: const Text("Add member"),
      content: TextField(
        controller: emailController,
        decoration: const InputDecoration(hintText: "Enter user email"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            final email = emailController.text.trim();
            if (email.isNotEmpty) {
              context.read<GroupChatCubit>().addMember(email);
              Navigator.pop(context);
            }
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}