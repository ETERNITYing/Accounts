part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class AppStartedEvent extends AuthEvent {} // App 剛開啟時檢查是否已登入

class SignInEvent extends AuthEvent {
  final String email;
  final String password;
  const SignInEvent({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}

class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  const SignUpEvent({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}

class SignOutEvent extends AuthEvent {}