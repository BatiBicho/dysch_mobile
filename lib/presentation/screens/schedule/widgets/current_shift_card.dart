import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CurrentShiftCard extends StatelessWidget {
  const CurrentShiftCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          // Parte superior con Imagen
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: Image.network(
                  'https://images.unsplash.com/photo-1497366216548-37526070297c',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Active Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Positioned(
                bottom: 12,
                left: 12,
                child: Text(
                  '08:00 AM - 05:00 PM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          // Info de Ubicación
          const ListTile(
            title: Text(
              'Sucursal Centro',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Av. Reforma 222, CDMX',
              style: TextStyle(fontSize: 12),
            ),
            trailing: CircleAvatar(
              backgroundColor: AppColors.surfaceBackground,
              child: Icon(Icons.near_me, color: AppColors.primaryOrange),
            ),
          ),
        ],
      ),
    );
  }
}
