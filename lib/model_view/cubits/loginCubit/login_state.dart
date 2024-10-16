part of 'login_cubit.dart';

@immutable
sealed class LoginState {}

final class LoginInitial extends LoginState {}

final class LoginLoadingState extends LoginState {}

final class LoginSuccessState extends LoginState {}

final class LoginErrorState extends LoginState {}

final class LoginKeepMeSignedInChanged extends LoginState {
  final bool keepMeSignedIn;
  LoginKeepMeSignedInChanged(this.keepMeSignedIn);
}
