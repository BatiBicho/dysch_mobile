import 'package:dysch_mobile/logic/auth/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomeHeader extends StatelessWidget {
  final String name;
  const HomeHeader({super.key, required this.name});

  String _getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('d MMMM yyyy');
    return formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Foto de Perfil con menú
          PopupMenuButton(
            offset: const Offset(0, 50),
            child: const CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=juan'),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Cerrar Sesión'),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthCubit>().logout(); // Lógica de tu Cubit
                context.go('/login');
              }
            },
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Hola, $name!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getFormattedDate(),
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          // Icono Notificación
          IconButton.filledTonal(
            onPressed: () {
              context.push('/notifications');
            },
            icon: const Badge(child: Icon(Icons.notifications_none)),
          ),
        ],
      ),
    );
  }
}
