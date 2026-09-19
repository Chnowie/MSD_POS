abstract class AuthEvent {
  const AuthEvent();
}

class AuthCheckRequested extends AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});
}

class RegisterSubmitted extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String role;

  const RegisterSubmitted({
    required this.username,
    required this.email,
    required this.password,
    this.role = 'KASIR',
  });
}

class LogoutRequested extends AuthEvent {}
