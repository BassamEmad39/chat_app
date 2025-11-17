import 'dart:async';

import 'package:chat_app/core/utils/app_colors.dart' show AppColors;
import 'package:chat_app/features/chat/chat_services.dart';
import 'package:chat_app/features/chat/group/pages/create_group_page.dart';
import 'package:chat_app/features/chat/group/cubit/group_list_cubit.dart';
import 'package:chat_app/features/chat/group/cubit/group_list_state.dart';
import 'package:chat_app/features/chat/group/pages/group_chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../components/user_tile.dart';

class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  final ChatService _chatService = ChatService();

  void _startGroupChat(String groupId, String groupName) async {
    final currentUserId = _chatService.currentUserId;
    if (currentUserId == null) return;

    await _chatService.markGroupMessagesAsRead(groupId, currentUserId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupChatPage(groupId: groupId, groupName: groupName),
      ),
    );
  }

  void _createNewGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateGroupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _chatService.currentUserId;
    if (currentUserId == null) {
      return const Center(child: Text('Not signed in'));
    }

    return BlocProvider(
      create: (context) => GroupListCubit(
        chatService: _chatService,
      ),
      child: Stack(
        children: [
          BlocBuilder<GroupListCubit, GroupListState>(
            builder: (context, state) {
              if (state is GroupListInitial || state is GroupListLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is GroupListError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${state.message}'),
                      const Gap(16),
                      ElevatedButton(
                        onPressed: () => context.read<GroupListCubit>().refreshGroups(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is GroupListLoaded && state.groups.isEmpty) {
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

              final groups = (state is GroupListLoaded 
                  ? state.groups 
                  : state is GroupListCreating 
                      ? state.groups 
                      : state is GroupListCreated 
                          ? state.groups 
                          : []) as List<Map<String, dynamic>>;

              return StreamBuilder<List<Map<String, dynamic>>>(
                stream: _getGroupsWithLatestMessages(groups, currentUserId),
                builder: (context, sortedGroupsSnapshot) {
                  if (!sortedGroupsSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final sortedGroups = sortedGroupsSnapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: sortedGroups.length,
                    itemBuilder: (context, index) {
                      final group = sortedGroups[index];
                      final groupId = group['id'] as String;
                      final groupName = group['name'] as String;
                      final lastMessage = group['lastMessage'] as String;
                      final sender = group['sender'] as String;
                      final timestampStr = group['timestampStr'] as String;
                      final unreadCount = group['unreadCount'] as int;

                      return UserTile(
                        text: groupName,
                        subtitle: lastMessage.isNotEmpty
                            ? '$sender: $lastMessage'
                            : 'No messages yet',
                        trailing: timestampStr.isNotEmpty
                            ? Text(
                                timestampStr,
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 12,
                                ),
                              )
                            : null,
                        unreadCount: unreadCount,
                        onTap: () => _startGroupChat(groupId, groupName),
                      );
                    },
                  );
                },
              );
            },
          ),

          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _createNewGroup,
              backgroundColor: const Color(0xFF06B6D4),
              child: const Icon(Icons.group_add, color: AppColors.whiteColor),
            ),
          ),
        ],
      ),
    );
  }

  Stream<List<Map<String, dynamic>>> _getGroupsWithLatestMessages(
      List<Map<String, dynamic>> groups, String currentUserId) {
    final Map<String, Map<String, dynamic>> groupDataMap = {};

    final StreamController<List<Map<String, dynamic>>> controller =
        StreamController<List<Map<String, dynamic>>>();

    for (final group in groups) {
      final groupId = group['id'] as String;

      _chatService.getGroupMessages(groupId).listen((snapshot) async {
        String lastMessage = '';
        String sender = '';
        String timestampStr = '';
        DateTime lastMessageTime = DateTime(0);

        if (snapshot.docs.isNotEmpty) {
          final lastDoc = snapshot.docs.last;
          final lastData = lastDoc.data() as Map<String, dynamic>;

          lastMessageTime = (lastData['timestamp'] as Timestamp).toDate();
          timestampStr = '${lastMessageTime.hour.toString().padLeft(2, '0')}:${lastMessageTime.minute.toString().padLeft(2, '0')}';

          sender = (lastData['senderId'] == currentUserId)
              ? 'You'
              : lastData['senderUsername'] ?? 'Unknown';

          lastMessage = lastData['message'] ?? '';
        }

        final unreadCount = await _chatService.getGroupUnreadCount(groupId, currentUserId);

        groupDataMap[groupId] = {
          ...group,
          'lastMessage': lastMessage,
          'sender': sender,
          'timestampStr': timestampStr,
          'unreadCount': unreadCount,
          'lastMessageTime': lastMessageTime,
        };

        // Emit sorted list
        final sortedGroups = groupDataMap.values.toList()
          ..sort((a, b) {
            final timeA = a['lastMessageTime'] as DateTime;
            final timeB = b['lastMessageTime'] as DateTime;
            return timeB.compareTo(timeA);
          });

        controller.add(sortedGroups);
      });
    }

    return controller.stream;
  }
}