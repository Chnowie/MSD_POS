import '../../../data/models/user_model.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;
  final bool isOfflineMode;

  const Authenticated({required this.user, required this.isOfflineMode});
}

class Unauthenticated extends AuthState {
  final String? message;
  const Unauthenticated({this.message});
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

class RegisterSuccess extends AuthState {
  final UserModel user;
  final String message;

  const RegisterSuccess({required this.user, required this.message});
}
