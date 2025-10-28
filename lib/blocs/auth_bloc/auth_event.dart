part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class AppStarted extends AuthEvent {}

class LoggedIn extends AuthEvent {
  final User user;
  LoggedIn(this.user);
}

class LoggedOut extends AuthEvent {}
class SignOutRequested extends AuthEvent {}
class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String username;
  SignUpRequested(this.email, this.password, this.username);
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}