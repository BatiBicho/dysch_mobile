import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:dysch_mobile/logic/profile/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

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
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileLoaded) {
            final user = state.user;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?u=${user.id}',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.jobPositionTitle,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ID: ${user.employeeCode}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('INFORMACION PERSONAL'),
                  _buildCard([
                    _buildInfoItem('Email', user.email),
                    _buildInfoItem('Telefono', user.phoneNumber),
                    _buildInfoItem('Empresa', user.companyName),
                    _buildInfoItem('Sucursal', user.branchName),
                    _buildInfoItem('Departamento', user.departmentName),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('DOCUMENTOS FISCALES'),
                  _buildCard([
                    _buildInfoItem('RFC', user.rfc),
                    _buildInfoItem('CURP', user.curp),
                    _buildInfoItem('Contrato', user.contractType),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('DATOS LABORALES'),
                  _buildCard([
                    _buildInfoItem(
                      'Dias de Vacaciones',
                      '${user.vacationDaysAvailable}',
                    ),
                    _buildInfoItem(
                      'Teletrabajo',
                      user.isRemoteWorkAllowed ? 'Permitido' : 'No permitido',
                    ),
                  ]),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Cerrar Sesion',
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
            );
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileCubit>().loadProfile(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Sin datos'));
        },
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

  Widget _buildInfoItem(String label, String value) => ListTile(
    title: Text(
      label,
      style: const TextStyle(fontSize: 12, color: Colors.grey),
    ),
    subtitle: Text(
      value,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  );
}
