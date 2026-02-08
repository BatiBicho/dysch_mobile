import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:dysch_mobile/presentation/screens/profile/profile_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Editar', style: TextStyle(color: Colors.orange)),
          ),
        ],
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header: Foto y Nombre
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                'https://i.pravatar.cc/150?u=carlos',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Carlos Rodríguez',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Ingeniero de Software',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'ID: MX-89201',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('INFORMACIÓN PERSONAL'),
            _buildCard([
              ProfileMenuItem(
                icon: Icons.person_outline,
                title: 'Datos Personales',
                subtitle: 'Email, Teléfono, Dirección',
                iconColor: AppColors.primary,
                onTap: () {},
              ),
              ProfileMenuItem(
                icon: Icons.description_outlined,
                title: 'Documentos Fiscales',
                subtitle: 'RFC, CURP, Constancia',
                iconColor: Colors.blue,
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 24),
            _buildSectionTitle('CONFIGURACIÓN'),
            _buildCard([
              _buildSwitchItem(
                Icons.notifications_none,
                'Notificaciones Push',
                true,
              ),
              _buildSwitchItem(
                Icons.face_retouching_natural,
                'FaceID / TouchID',
                true,
              ),
            ]),

            const SizedBox(height: 32),
            // Botón Cerrar Sesión
            OutlinedButton.icon(
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEEEEEE)),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(left: 8, bottom: 8),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    ),
  );

  Widget _buildCard(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(children: children),
  );

  Widget _buildSwitchItem(IconData icon, String title, bool value) => ListTile(
    leading: Icon(icon, color: Colors.purple),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
    trailing: Switch(
      value: value,
      onChanged: (v) {},
      activeThumbColor: AppColors.primary,
    ),
  );
}
