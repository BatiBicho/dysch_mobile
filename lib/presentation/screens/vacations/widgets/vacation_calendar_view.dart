import 'package:flutter/material.dart';

class VacationCalendarView extends StatelessWidget {
  const VacationCalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.chevron_left, color: Colors.grey),
              Text(
                'Noviembre 2023',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 20),
          // Días de la semana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                .map(
                  (d) => Text(
                    d,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          // Aquí iría el GridView.builder para los días reales
          // Simulamos la fila de vacaciones (15 al 18)
          _buildCalendarRow(),
        ],
      ),
    );
  }

  Widget _buildCalendarRow() {
    // Ejemplo de cómo se vería la fila seleccionada
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Text('13', style: TextStyle(color: Colors.black)),
          const Text('14', style: TextStyle(color: Colors.black)),
          _daySelected('15', isStart: true),
          _daySelected('16', isMiddle: true),
          _daySelected('17', isMiddle: true),
          _daySelected('18', isEnd: true),
          const Text('19', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _daySelected(
    String day, {
    bool isStart = false,
    bool isMiddle = false,
    bool isEnd = false,
  }) {
    return Container(
      width: 40,
      height: 35,
      decoration: BoxDecoration(
        color: const Color(0xFFFF7043),
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(isStart ? 12 : 0),
          right: Radius.circular(isEnd ? 12 : 0),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        day,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
