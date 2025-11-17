import 'package:chat_app/features/chat/chat_services.dart';
import 'package:chat_app/features/chat/group/cubit/group_chat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupMembersDialog extends StatelessWidget {
  final String groupId;
  final String groupName;
  final ChatService chatService;

  const GroupMembersDialog({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.chatService,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = chatService.currentUserId;

    return AlertDialog(
      title: Text("$groupName Members"),
      content: SizedBox(
        width: double.maxFinite,
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: chatService.getGroupMembersStream(groupId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();

            final members = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              itemCount: members.length,
              itemBuilder: (_, index) {
                final member = members[index];
                final isMe = member['id'] == currentUserId;
                final isAdmin = member['isAdmin'] as bool;
                final canManage = member['canManage'] as bool? ?? false;

                return ListTile(
                  title: Text(
                    member['username'],
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    isAdmin ? "Admin" : "Member",
                    style: TextStyle(
                      color: isAdmin ? Colors.blue : Colors.grey,
                    ),
                  ),
                  trailing: !isMe && canManage
                      ? PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'remove') {
                              context.read<GroupChatCubit>().removeMember(
                                member['id'],
                              );
                            } else if (value == 'makeAdmin') {
                              context
                                  .read<GroupChatCubit>()
                                  .updateAdminStatus(member['id'], true);
                            } else if (value == 'revokeAdmin') {
                              context
                                  .read<GroupChatCubit>()
                                  .updateAdminStatus(member['id'], false);
                            }
                          },
                          itemBuilder: (context) => [
                            if (!isAdmin)
                              const PopupMenuItem(
                                value: 'makeAdmin',
                                child: Text('Make Admin'),
                              ),
                            if (isAdmin)
                              const PopupMenuItem(
                                value: 'revokeAdmin',
                                child: Text('Revoke Admin'),
                              ),
                            const PopupMenuItem(
                              value: 'remove',
                              child: Text('Remove'),
                            ),
                          ],
                        )
                      : null,
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }
}