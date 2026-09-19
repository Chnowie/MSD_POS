import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authService.login(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user: user, isOfflineMode: !user.isSynced)),
    );
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authService.register(
      username: event.username,
      email: event.email,
      password: event.password,
      role: event.role,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(
        RegisterSuccess(
          user: user,
          message:
              "Akun '${user.username}' berhasil didaftarkan! Silakan login.",
        ),
      ),
    );
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    emit(const Unauthenticated(message: "Anda telah keluar dari aplikasi."));
  }
}
