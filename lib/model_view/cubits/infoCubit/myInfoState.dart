import 'package:equatable/equatable.dart';
import 'package:visit_man/model/userModel/detailsUser.dart';
import 'package:visit_man/model/userModel/userModel.dart';

abstract class MyInfoState extends Equatable {
  const MyInfoState();

  @override
  List<Object> get props => [];
}

class MyInfoInitial extends MyInfoState {}

class MyInfoLoading extends MyInfoState {}

class MyInfoLoaded extends MyInfoState {
  final dynamic data;

  MyInfoLoaded(this.data);
}


class MyInfoError extends MyInfoState {
  final String message;

  const MyInfoError(this.message);

  @override
  List<Object> get props => [message];
}