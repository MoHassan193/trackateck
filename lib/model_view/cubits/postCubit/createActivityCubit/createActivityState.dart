import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

// State Definitions
abstract class CreateActivityState extends Equatable {
  const CreateActivityState();

  @override
  List<Object> get props => [];
}

class CreateActivityInitial extends CreateActivityState {}

class CreateActivityLoading extends CreateActivityState {}

class CreateActivitySuccess extends CreateActivityState {
  final String message;

  const CreateActivitySuccess(this.message);

  @override
  List<Object> get props => [message];
}

class CreateActivityFailure extends CreateActivityState {
  final String error;

  const CreateActivityFailure(this.error);

  @override
  List<Object> get props => [error];
}


