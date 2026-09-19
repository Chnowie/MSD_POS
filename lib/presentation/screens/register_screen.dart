import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String _selectedRole = 'KASIR';

  final List<Map<String, dynamic>> _roles = [
    {
      'value': 'KASIR',
      'label': 'Kasir',
      'icon': Icons.point_of_sale,
      'color': Colors.blue,
      'desc': 'Akses transaksi penjualan',
    },
    {
      'value': 'ADMIN',
      'label': 'Admin',
      'icon': Icons.admin_panel_settings,
      'color': Colors.indigo,
      'desc': 'Kelola inventori & laporan',
    },
    {
      'value': 'OWNER',
      'label': 'Owner',
      'icon': Icons.star_rounded,
      'color': Colors.teal,
      'desc': 'Akses penuh semua fitur',
    },
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            RegisterSubmitted(
              username: _usernameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              role: _selectedRole,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Akun Baru"),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: 'Kembali ke halaman login',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
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
          } else if (state is RegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.white),
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
            // Kembali ke layar login setelah sukses register
            Navigator.of(context).pop();
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Icon(
                        Icons.person_add_rounded,
                        size: 64,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Buat Akun Baru",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Isi data di bawah untuk mendaftarkan akun pengguna baru",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Input Username
                      Semantics(
                        label: "Input Nama Pengguna",
                        hint: "Masukkan nama pengguna unik",
                        child: TextFormField(
                          controller: _usernameController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.none,
                          decoration: const InputDecoration(
                            labelText: "Nama Pengguna (Username)",
                            hintText: "contoh: budi_kasir",
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Nama pengguna wajib diisi";
                            }
                            if (value.trim().length < 3) {
                              return "Nama pengguna minimal 3 karakter";
                            }
                            if (value.trim().contains(' ')) {
                              return "Nama pengguna tidak boleh mengandung spasi";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Input Email
                      Semantics(
                        label: "Input Email",
                        hint: "Masukkan alamat email aktif",
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            hintText: "kasir@toko.com",
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Email wajib diisi";
                            }
                            if (!value.contains('@') ||
                                !value.contains('.')) {
                              return "Format email tidak valid";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Input Password
                      Semantics(
                        label: "Input Password Baru",
                        hint: "Masukkan password minimal 6 karakter",
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: "Password",
                            hintText: "Minimal 6 karakter",
                            prefixIcon:
                                const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () => setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              }),
                              tooltip: _isPasswordVisible
                                  ? "Sembunyikan Password"
                                  : "Tampilkan Password",
                            ),
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
                      const SizedBox(height: 16),

                      // Input Konfirmasi Password
                      Semantics(
                        label: "Input Konfirmasi Password",
                        hint: "Masukkan ulang password yang sama",
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _onRegisterPressed(),
                          decoration: InputDecoration(
                            labelText: "Konfirmasi Password",
                            hintText: "Ulangi password di atas",
                            prefixIcon:
                                const Icon(Icons.lock_reset_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () => setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              }),
                              tooltip: _isConfirmPasswordVisible
                                  ? "Sembunyikan Password"
                                  : "Tampilkan Password",
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Konfirmasi password wajib diisi";
                            }
                            if (value != _passwordController.text) {
                              return "Password tidak cocok";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Pilih Role
                      Text(
                        "Pilih Role Pengguna:",
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._roles.map((role) {
                        final isSelected = _selectedRole == role['value'];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () =>
                                setState(() => _selectedRole = role['value']),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? (role['color'] as Color)
                                      : colorScheme.outline.withValues(alpha: 0.4),
                                  width: isSelected ? 2 : 1,
                                ),
                                color: isSelected
                                    ? (role['color'] as Color).withValues(alpha: 0.08)
                                    : Colors.transparent,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    role['icon'] as IconData,
                                    color: isSelected
                                        ? role['color'] as Color
                                        : colorScheme.onSurface
                                            .withValues(alpha: 0.5),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          role['label'] as String,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? role['color'] as Color
                                                : colorScheme.onSurface,
                                          ),
                                        ),
                                        Text(
                                          role['desc'] as String,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: colorScheme.onSurface
                                                .withValues(alpha: 0.55),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: role['color'] as Color,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),

                      // Tombol Daftar
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;
                          return ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 48),
                            child: FilledButton.icon(
                              onPressed: isLoading ? null : _onRegisterPressed,
                              icon: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.person_add_rounded),
                              label: Text(
                                isLoading
                                    ? "Mendaftarkan..."
                                    : "DAFTAR SEKARANG",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Kembali ke Login
                      Center(
                        child: TextButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.login_rounded, size: 18),
                          label: const Text("Sudah punya akun? Masuk"),
                        ),
                      ),
                      const SizedBox(height: 8),
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
