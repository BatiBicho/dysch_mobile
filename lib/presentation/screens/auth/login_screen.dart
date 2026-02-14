import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dysch_mobile/logic/auth/auth_cubit.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // --- LOGO ---
              const Text(
                'DYSCH',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 30),

              // --- ILUSTRACIÓN / BANNER ---
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  children: [
                    Image.network(
                      'https://img.freepik.com/free-vector/office-workers-concept-illustration_114360-1248.jpg',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: .7),
                          ],
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 20,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bienvenido de nuevo',
                            style: TextStyle(
                              color: AppColors.onPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Gestiona tu nómina y asistencia',
                            style: TextStyle(
                              color: AppColors.onPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- FORMULARIO ---
              _buildInputLabel('Correo corporativo'),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'usuario@empresa.com',
                  hintStyle: TextStyle(
                    color: AppColors.primary.withValues(alpha: .5),
                  ),
                  suffixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColors.primary.withValues(alpha: .7),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildInputLabel('Contraseña'),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: TextStyle(
                    color: AppColors.primary.withValues(alpha: .5),
                  ),
                  suffixIcon: Icon(
                    Icons.visibility_outlined,
                    color: AppColors.primary.withValues(alpha: .7),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- BOTÓN DE LOGIN CON BLOC ---
              BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    // ¡ÉXITO! Navegamos al Home
                    context.go('/home');
                  } else if (state is AuthError) {
                    // Error: mostramos un SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state is AuthLoading
                        ? null
                        : () => context.read<AuthCubit>().login(
                            emailController.text,
                            passwordController.text,
                          ),
                    child: state is AuthLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Entrar"),
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: AppColors.onBackground,
        ),
      ),
    );
  }
}
