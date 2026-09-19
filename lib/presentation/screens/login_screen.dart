import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import 'main_navigation_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  bool get _isOnline {
    try {
      final authService = context.read<AuthBloc>().authService;
      return authService.isSupabaseConfigured;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginSubmitted(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  void _fillDemoAccount(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
    });
  }

  void _goToRegister() {
    // Reset state BLoC ke AuthInitial agar RegisterScreen bisa emit dari clean state
    context.read<AuthBloc>().add(LogoutRequested());

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login POS Toko Sparepart"),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white,
                        size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          } else if (state is Authenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Selamat datang, ${state.user.username} (${state.user.role})!"
                        " ${state.isOfflineMode ? '[Mode Offline]' : '[Mode Online]'}",
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 2),
              ),
            );

            // Navigasi ke Layar Utama
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => MainNavigationScreen(
                  currentUser: state.user,
                  isOfflineMode: state.isOfflineMode,
                ),
              ),
            );
          } else if (state is RegisterSuccess) {
            // Jika user balik dari register screen dan state masih RegisterSuccess,
            // tampilkan pesan sukses dan kosongkan form agar user bisa login
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 3),
              ),
            );
            // Pre-fill email agar user langsung bisa login
            setState(() {
              _emailController.text = state.user.email;
              _passwordController.clear();
            });
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo / Header Icon
                      Icon(
                        Icons.build_circle_rounded,
                        size: 80,
                        color: colorScheme.primary,
                        semanticLabel: "Logo Toko Sparepart",
                      ),
                      const SizedBox(height: 16),

                      Text(
                        "POS & Invoicing Sparepart",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Indikator Status Koneksi (Online / Offline Backup)
                      Semantics(
                        label: _isOnline
                            ? "Status Koneksi: Online Supabase"
                            : "Status Koneksi: Offline Isar DB",
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: _isOnline
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isOnline ? Icons.wifi : Icons.wifi_off,
                                size: 16,
                                color: _isOnline
                                    ? Colors.green.shade900
                                    : Colors.orange.shade900,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isOnline
                                    ? "Mode Online (Supabase Sync)"
                                    : "Mode Offline (Isar Local Backup)",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _isOnline
                                      ? Colors.green.shade900
                                      : Colors.orange.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Quick Fill Demo Accounts
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Cepat Pilih Akun Demo (Uji Coba):",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                ActionChip(
                                  avatar: Icon(Icons.star, size: 16,
                                      color: Colors.teal.shade700),
                                  label: const Text("Owner",
                                      style: TextStyle(fontSize: 12)),
                                  onPressed: () => _fillDemoAccount(
                                      'owner@pos.com', 'password123'),
                                ),
                                ActionChip(
                                  avatar: Icon(Icons.admin_panel_settings,
                                      size: 16, color: Colors.indigo.shade600),
                                  label: const Text("Admin",
                                      style: TextStyle(fontSize: 12)),
                                  onPressed: () => _fillDemoAccount(
                                      'admin@pos.com', 'password123'),
                                ),
                                ActionChip(
                                  avatar: Icon(Icons.point_of_sale, size: 16,
                                      color: Colors.blue.shade600),
                                  label: const Text("Kasir",
                                      style: TextStyle(fontSize: 12)),
                                  onPressed: () => _fillDemoAccount(
                                      'kasir@pos.com', 'password123'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Input Email
                      Semantics(
                        label: "Input Email Pengguna",
                        hint: "Masukkan alamat email yang terdaftar",
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            hintText: "kasir@pos.com",
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Email wajib diisi";
                            }
                            if (!value.contains("@")) {
                              return "Format email tidak valid";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Input Password
                      Semantics(
                        label: "Input Password",
                        hint: "Masukkan password akun anda",
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _onLoginPressed(),
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              tooltip: _isPasswordVisible
                                  ? "Sembunyikan Password"
                                  : "Tampilkan Password",
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password wajib diisi";
                            }
                            if (value.length < 6) {
                              return "Password minimal 6 karakter";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tombol Login
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;

                          return ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 48),
                            child: FilledButton.icon(
                              onPressed: isLoading ? null : _onLoginPressed,
                              icon: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.login_rounded),
                              label: Text(
                                isLoading ? "Memproses..." : "MASUK APLIKASI",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // Divider dengan teks "atau"
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              "atau",
                              style: TextStyle(
                                color:
                                    colorScheme.onSurface.withValues(alpha: 0.45),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Tombol Daftar Akun Baru
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: OutlinedButton.icon(
                          onPressed: _goToRegister,
                          icon: const Icon(Icons.person_add_rounded),
                          label: const Text(
                            "DAFTAR AKUN BARU",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
