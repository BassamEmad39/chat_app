import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class PrivateChatState extends Equatable {
  const PrivateChatState();
  
  List<DocumentSnapshot> get messages => [];

  @override
  List<Object?> get props => [];
}

class PrivateChatInitial extends PrivateChatState {}

class PrivateChatLoading extends PrivateChatState {}

class PrivateChatLoaded extends PrivateChatState {
  final List<DocumentSnapshot> _messages;
  final bool hasUnreadMessages;
  
  const PrivateChatLoaded({
    required List<DocumentSnapshot> messages,
    required this.hasUnreadMessages,
  }) : _messages = messages;

  @override
  List<DocumentSnapshot> get messages => _messages;

  @override
  List<Object?> get props => [_messages, hasUnreadMessages];
}

class PrivateChatError extends PrivateChatState {
  final String message;
  
  const PrivateChatError(this.message);

  @override
  List<Object?> get props => [message];
}

class PrivateChatMessageSending extends PrivateChatState {
  final List<DocumentSnapshot> _messages;
  
  const PrivateChatMessageSending(this._messages);

  @override
  List<DocumentSnapshot> get messages => _messages;

  @override
  List<Object?> get props => [_messages];
}

class PrivateChatMessageSent extends PrivateChatState {
  final List<DocumentSnapshot> _messages;
  
  const PrivateChatMessageSent(this._messages);

  @override
  List<DocumentSnapshot> get messages => _messages;

  @override
  List<Object?> get props => [_messages];
}