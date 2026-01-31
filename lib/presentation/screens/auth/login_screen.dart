import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
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
                  color: AppColors.primaryOrange,
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
                            Colors.black.withOpacity(0.7),
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
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Gestiona tu nómina y asistencia',
                            style: TextStyle(
                              color: Colors.white70,
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
                decoration: InputDecoration(
                  hintText: 'usuario@empresa.com',
                  hintStyle: TextStyle(
                    color: AppColors.primaryOrange.withOpacity(0.5),
                  ),
                  suffixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColors.primaryOrange.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildInputLabel('Contraseña'),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: TextStyle(
                    color: AppColors.primaryOrange.withOpacity(0.5),
                  ),
                  suffixIcon: Icon(
                    Icons.visibility_outlined,
                    color: AppColors.primaryOrange.withOpacity(0.7),
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
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- BOTÓN PRINCIPAL ---
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward),
                label: const Text(
                  'Iniciar Sesión',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  minimumSize: const Size(double.infinity, 60),
                ),
              ),

              const SizedBox(height: 30),

              // --- DIVIDER ---
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'o ingresa con',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),

              // --- FACE ID ---
              IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.face_retouching_natural, size: 32),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.white,
                ),
              ),
              const Text(
                'Face ID',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 40),
              const Text(
                'DYSCH v1.0.2',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
              const SizedBox(height: 20),
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
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
