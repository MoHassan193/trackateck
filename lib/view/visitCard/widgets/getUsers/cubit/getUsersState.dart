abstract class GetUsersState {}

class GetUsersInitial extends GetUsersState {}

class GetUsersLoading extends GetUsersState {}

class GetUsersLoaded extends GetUsersState {
  final List<dynamic> users;

  GetUsersLoaded(this.users);
}

class GetUsersError extends GetUsersState {
  final String message;

  GetUsersError(this.message);
}
