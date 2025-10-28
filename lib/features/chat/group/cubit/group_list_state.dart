import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class GroupListState extends Equatable {
  const GroupListState();
  
  @override
  List<Object?> get props => [];
}

class GroupListInitial extends GroupListState {}

class GroupListLoading extends GroupListState {}

class GroupListLoaded extends GroupListState {
  final List<Map<String, dynamic>> groups;
  
  const GroupListLoaded(this.groups);

  @override
  List<Object?> get props => [groups];
}

class GroupListError extends GroupListState {
  final String message;
  
  const GroupListError(this.message);

  @override
  List<Object?> get props => [message];
}

class GroupListCreating extends GroupListState {
  final List<Map<String, dynamic>> groups;
  
  const GroupListCreating(this.groups);

  @override
  List<Object?> get props => [groups];
}

class GroupListCreated extends GroupListState {
  final List<Map<String, dynamic>> groups;
  
  const GroupListCreated(this.groups);

  @override
  List<Object?> get props => [groups];
}