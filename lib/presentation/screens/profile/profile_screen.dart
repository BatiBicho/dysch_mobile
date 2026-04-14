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

    // Obtención de iniciales:
    String _getInitials(String fullName) {
        final parts = fullName.trim().split(' ');

        if (parts.length >= 2) {
            return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
        } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
            return parts[0][0].toUpperCase();
        }

        return '?';
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: AppColors.background,
            body: BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                    if (state is ProfileLoading) {
                            return const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                        );
                    }

                    if (state is ProfileLoaded) {
                        final user = state.user;

                        return Column(
                            children: [
                                Container(
                                    width: double.infinity,

                                    decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.vertical(
                                            bottom: Radius.circular(16),
                                        ),
                                    ),

                                    child: SafeArea(
                                        bottom: false,
                                        child: Column(
                                            children: [

                                                // Flechita de regresar:
                                                Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Padding(
                                                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                                                        child: GestureDetector(
                                                            onTap: () => context.pop(),
                                                            child: const SizedBox(
                                                                width: 38,
                                                                height: 38,
                                                                child: Icon(
                                                                    Icons.arrow_back_ios_new_rounded,
                                                                    color: Colors.white,
                                                                    size: 16,
                                                                ),
                                                            ),
                                                        ),
                                                    ),
                                                ),

                                                const SizedBox(height: 10),

                                                Padding(
                                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                            Container(
                                                                width: 80, height: 80,
                                                                decoration: const BoxDecoration(
                                                                    color: Color(0xFFF6F7FB),
                                                                    shape: BoxShape.circle,
                                                                ),

                                                                child: Center(
                                                                    child: Text(
                                                                        _getInitials(user.fullName),
                                                                        style: const TextStyle(
                                                                            color: Color(0xFFF56B39),
                                                                            fontSize: 28,
                                                                            fontWeight: FontWeight.w900,
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),

                                                            const SizedBox(height: 16),

                                                            Text(
                                                                user.fullName,
                                                                textAlign: TextAlign.center,
                                                                style: const TextStyle(
                                                                    fontSize: 22,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: Colors.white,
                                                                ),
                                                            ),

                                                            const SizedBox(height: 6),

                                                            Text(
                                                                user.jobPositionTitle,
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                    color: Colors.white.withOpacity(0.75),
                                                                    fontSize: 14,
                                                                ),
                                                            ),

                                                            const SizedBox(height: 12),

                                                            Container(
                                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                                decoration: BoxDecoration(
                                                                    color: Colors.black.withOpacity(0.12),
                                                                    borderRadius: BorderRadius.circular(12),
                                                                ),

                                                                child: Text(
                                                                    'ID: ${user.employeeCode}',
                                                                    style: const TextStyle(
                                                                        color: Colors.white,
                                                                        fontWeight: FontWeight.w700,
                                                                        fontSize: 11,
                                                                    ),
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                )
                                            ],
                                        ),
                                    ),
                                ),

                                // Contenido:
                                Expanded(
                                    child: Container(
                                        decoration: const BoxDecoration(
                                            color: AppColors.background,
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                        ),

                                        child: ClipRRect(
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                            child: SingleChildScrollView(
                                                padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                        _buildSectionTitle('INFORMACIÓN PERSONAL'),
                                                        _buildCard([
                                                            _buildInfoItem(Icons.email_outlined, 'Email', user.email),
                                                            _buildDivider(),
                                                            _buildInfoItem(Icons.phone_outlined, 'Teléfono', user.phoneNumber),
                                                        ]),

                                                        const SizedBox(height: 20),

                                                        _buildSectionTitle('DOCUMENTOS FISCALES'),
                                                        _buildCard([
                                                            _buildInfoItem(Icons.badge_outlined, 'RFC', user.rfc),
                                                            _buildDivider(),
                                                            _buildInfoItem(Icons.fingerprint_outlined, 'CURP', user.curp),
                                                            _buildDivider(),
                                                            _buildInfoItem(Icons.description_outlined, 'Contrato', user.contractType),
                                                        ]),

                                                        const SizedBox(height: 20),

                                                        _buildSectionTitle('DATOS LABORALES'),
                                                        _buildCard([
                                                            _buildInfoItem(Icons.business_outlined, 'Empresa', user.companyName),
                                                            _buildDivider(),
                                                            _buildInfoItem(Icons.store_outlined, 'Sucursal', user.branchName),
                                                            _buildDivider(),
                                                            _buildInfoItem(Icons.category_outlined, 'Departamento', user.departmentName),
                                                            _buildDivider(),
                                                            _buildInfoItem(
                                                                Icons.beach_access_outlined,
                                                                'Días de vacaciones',
                                                                '${user.vacationDaysAvailable} días disponibles',
                                                            ),
                                                            _buildDivider(),
                                                            _buildInfoItem(
                                                                Icons.laptop_outlined,
                                                                'Teletrabajo',
                                                                user.isRemoteWorkAllowed ? 'Permitido' : 'No permitido',
                                                                valueColor: user.isRemoteWorkAllowed
                                                                    ? AppColors.success
                                                                    : AppColors.error,
                                                            ),
                                                        ]),

                                                        const SizedBox(height: 28),

                                                        GestureDetector(
                                                            onTap: () => context.go('/login'),
                                                            child: Container(
                                                                height: 54,
                                                                decoration: BoxDecoration(
                                                                    color: AppColors.surface,
                                                                    borderRadius: BorderRadius.circular(14),
                                                                    border: Border.all(color: AppColors.outline),
                                                                ),

                                                                child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: const [
                                                                        Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                                                                        SizedBox(width: 8),
                                                                        Text(
                                                                            'Cerrar Sesión',
                                                                            style: TextStyle(
                                                                                color: AppColors.error,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontSize: 14,
                                                                            ),
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                        ),
                                    ),
                                ),
                            ]
                        );
                    }

                    if (state is ProfileError) {
                        return Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                                    const SizedBox(height: 16),

                                    Text(
                                        state.message,
                                        style: const TextStyle(color: AppColors.onSurfaceVariant),
                                        textAlign: TextAlign.center,
                                    ),

                                    const SizedBox(height: 16),

                                    ElevatedButton(
                                        onPressed: () => context.read<ProfileCubit>().loadProfile(),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: AppColors.onPrimary,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                            ),
                                        ),

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
        padding: const EdgeInsets.only(left: 2, bottom: 8),
        child: Text(
        title,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1.2,
        ),
        ),
    );

    Widget _buildCard(List<Widget> children) => Container(
        decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: children),
    );

    Widget _buildDivider() => const Divider(
        height: 1,
        thickness: 1,
        color: AppColors.outline,
        indent: 50,
        endIndent: 0,
    );

    Widget _buildInfoItem(
        IconData icon,
        String label,
        String value, {
        Color? valueColor,
    }) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 14),

                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(
                                label,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                ),
                            ),

                            const SizedBox(height: 1),

                            Text(
                                value,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: valueColor ?? AppColors.onSurface,
                                ),
                            ),
                        ],
                    ),
                ),
            ],
        ),
    );
}