import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class GroupChatState extends Equatable {
  const GroupChatState();

  @override
  List<Object?> get props => [];
}

class GroupChatInitial extends GroupChatState {}

class GroupChatLoading extends GroupChatState {}

class GroupChatLoaded extends GroupChatState {
  final List<DocumentSnapshot> messages;
  final bool hasUnreadMessages;
  
  const GroupChatLoaded({
    required this.messages,
    required this.hasUnreadMessages,
  });

  @override
  List<Object?> get props => [messages, hasUnreadMessages];
}

class GroupChatError extends GroupChatState {
  final String message;
  
  const GroupChatError(this.message);

  @override
  List<Object?> get props => [message];
}

class GroupChatMessageSending extends GroupChatState {
  final List<DocumentSnapshot> messages;
  
  const GroupChatMessageSending(this.messages);

  @override
  List<Object?> get props => [messages];
}

class GroupChatMessageSent extends GroupChatState {
  final List<DocumentSnapshot> messages;
  
  const GroupChatMessageSent(this.messages);

  @override
  List<Object?> get props => [messages];
}

class GroupChatMembersLoading extends GroupChatState {
  final List<DocumentSnapshot> messages;
  
  const GroupChatMembersLoading(this.messages);

  @override
  List<Object?> get props => [messages];
}

class GroupChatMembersLoaded extends GroupChatState {
  final List<DocumentSnapshot> messages;
  final List<Map<String, dynamic>> members;
  
  const GroupChatMembersLoaded({
    required this.messages,
    required this.members,
  });

  @override
  List<Object?> get props => [messages, members];
}