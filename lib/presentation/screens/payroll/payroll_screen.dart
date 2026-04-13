import 'package:flutter/material.dart';
import 'widgets/prenomina/prenomina_section.dart';

class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
        child: const PrenominaSection(),
      ),
    );
  }
}
