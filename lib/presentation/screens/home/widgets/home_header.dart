import 'package:dysch_mobile/logic/auth/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomeHeader extends StatelessWidget {
  final String name;
  const HomeHeader({super.key, required this.name});

  // Fecha actual:
  String _getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat("d 'de' MMMM 'de' yyyy", 'es');
    return formatter.format(now);
  }

  // Iniciales del nombre:
  String _getInitials(String fullName) {
    if (fullName.trim().isEmpty) return "?";

    List<String> names = fullName.trim().split(RegExp(r'\s+'));
    String initials = "";

    for (var i = 0; i < names.length && i < 2; i++) {
      if (names[i].isNotEmpty) {
        initials += names[i][0].toUpperCase();
      }
    }

    return initials;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Menú con iniciales del usuario:
          PopupMenuButton(
            offset: const Offset(0, 50),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                _getInitials(name),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Cerrar sesión'),
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
                '¡Hola de nuevo, $name!',
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

          IconButton(
            onPressed: () => context.push('/notifications'),
            icon: Badge(
              padding: const EdgeInsets.all(4),
              largeSize: 12,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 24,
              ),
            ),
          )
        ],
      ),
    );
  }
}
