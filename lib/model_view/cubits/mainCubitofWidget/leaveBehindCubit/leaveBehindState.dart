import 'package:equatable/equatable.dart';
import 'package:visit_man/model/userModel/leaveBehindModel.dart';

abstract class LeaveBehindState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LeaveBehindInitial extends LeaveBehindState {}

class LeaveBehindLoading extends LeaveBehindState {}

class LeaveBehindLoaded extends LeaveBehindState {
  final List<dynamic> leaveBehinds;

  LeaveBehindLoaded(this.leaveBehinds);

  @override
  List<Object?> get props => [leaveBehinds];
}

class LeaveBehindError extends LeaveBehindState {
  final String message;

  LeaveBehindError(this.message);

  @override
  List<Object?> get props => [message];
}