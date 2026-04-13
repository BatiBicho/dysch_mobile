
import 'package:dysch_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dysch_mobile/logic/auth/auth_cubit.dart';


class LoginScreen extends StatefulWidget {
    const LoginScreen({super.key});

    @override
    State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
    late TextEditingController _emailController;
    late TextEditingController _passwordController;
    late FocusNode _emailFocus;
    late FocusNode _passwordFocus;
    late AnimationController _fadeController;
    late Animation<double> _fadeAnim;
    late Animation<Offset> _slideAnim;

    bool _isPasswordVisible = false;
    bool _emailFocused    = false;
    bool _passwordFocused = false;
    bool _emailHasError    = false;
    bool _passwordHasError = false;

    @override
    void initState() {
        super.initState();
        _emailController    = TextEditingController();
        _passwordController = TextEditingController();
        _emailFocus    = FocusNode();
        _passwordFocus = FocusNode();

        _fadeController = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 520),
        )..forward();

        _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
            _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
        ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

        _emailFocus.addListener(
            () => setState(() => _emailFocused = _emailFocus.hasFocus),
            );
            _passwordFocus.addListener(
            () => setState(() => _passwordFocused = _passwordFocus.hasFocus),
        );
    }

    @override
    void dispose() {
        _emailController.dispose();
        _passwordController.dispose();
        _emailFocus.dispose();
        _passwordFocus.dispose();
        _fadeController.dispose();
        super.dispose();
    }

    bool _validate() {
        final email    = _emailController.text.trim();
        final password = _passwordController.text;

        setState(() {
            _emailHasError    = email.isEmpty || !email.contains('@');
            _passwordHasError = password.isEmpty;
        });

        return !_emailHasError && !_passwordHasError;
    }

    void _submit(BuildContext context) {
        if (!_validate()) return;
        FocusScope.of(context).unfocus();

        context.read<AuthCubit>().login(
            _emailController.text.trim(),
            _passwordController.text,
        );
    }

    @override
    Widget build(BuildContext context) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: Scaffold(
                backgroundColor: AppColors.background,
                body: BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {

                        if (state is AuthSuccess) {
                            context.go('/home');
                        } else if (state is AuthError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Row(children: [
                                        const Icon(Icons.error_outline, color: Colors.white, size: 18),
                                        const SizedBox(width: 10),
                                        Expanded(child: Text(state.message)),
                                    ]),

                                    backgroundColor: AppColors.error,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    margin: const EdgeInsets.all(16),
                                ),
                            );
                        }
                    },

                    builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return SafeArea(
                            child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(horizontal: 28),
                                child: FadeTransition(
                                    opacity: _fadeAnim,
                                    child: SlideTransition(
                                        position: _slideAnim,
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                const SizedBox(height: 48),

                                                Center(
                                                    child: Image.asset(
                                                        'assets/images/logo3.png',
                                                        height: 192,
                                                    ),
                                                ),

                                                const SizedBox(height: 48),

                                                RichText(
                                                    text: const TextSpan(
                                                        style: TextStyle(
                                                            fontSize: 30,
                                                            fontWeight: FontWeight.w900,
                                                            color: AppColors.onBackground,
                                                            height: 1.15,
                                                        ),

                                                        children: [
                                                            TextSpan(text: 'Bienvenido'),

                                                            TextSpan(text: '.',
                                                                style: TextStyle(color: AppColors.primary),
                                                            ),
                                                        ],
                                                    ),
                                                ),

                                                const SizedBox(height: 8),

                                                const Text(
                                                    'Accede para gestionar tu nómina y asistencia.',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: AppColors.onSurfaceVariant,
                                                        height: 1.45,
                                                    ),
                                                ),

                                                const SizedBox(height: 36),

                                                _FieldLabel(label: 'CORREO CORPORATIVO'),
                                                const SizedBox(height: 8),
                                                _InputField(
                                                    controller: _emailController,
                                                    focusNode: _emailFocus,
                                                    nextFocus: _passwordFocus,
                                                    hintText: 'usuario@empresa.com',
                                                    keyboardType: TextInputType.emailAddress,
                                                    prefixIcon: Icons.mail_outline_rounded,
                                                    hasError: _emailHasError,
                                                    isFocused: _emailFocused,
                                                    errorText: 'Ingrese un correo válido',
                                                    onChanged: (_) {
                                                        if (_emailHasError)
                                                        setState(() => _emailHasError = false);
                                                    },
                                                ),

                                                const SizedBox(height: 20),

                                                _FieldLabel(label: 'CONTRASEÑA'),
                                                const SizedBox(height: 8),
                                                _InputField(
                                                    controller: _passwordController,
                                                    focusNode: _passwordFocus,
                                                    hintText: '••••••••',
                                                    obscureText: !_isPasswordVisible,
                                                    prefixIcon: Icons.lock_outline_rounded,
                                                    hasError: _passwordHasError,
                                                    isFocused: _passwordFocused,
                                                    errorText: 'Ingrese su contraseña',
                                                    onChanged: (_) {
                                                        if (_passwordHasError)
                                                        setState(() => _passwordHasError = false);
                                                    },
                                                    onSubmitted: (_) => _submit(context),
                                                    suffixIcon: IconButton(
                                                        icon: Icon(
                                                            _isPasswordVisible
                                                                ? Icons.visibility_outlined
                                                                : Icons.visibility_off_outlined,
                                                            color: AppColors.onSurfaceVariant,
                                                            size: 20,
                                                        ),
                                                        onPressed: () => setState(
                                                            () => _isPasswordVisible = !_isPasswordVisible,
                                                        ),
                                                    ),
                                                ),

                                                const SizedBox(height: 32),

                                                _LoginButton(
                                                    isLoading: isLoading,
                                                    onPressed: () => _submit(context),
                                                ),

                                                const SizedBox(height: 36),

                                                Center(
                                                    child: Text(
                                                        '© 2026 DYSCH. Todos los derechos reservados.',
                                                        style: const TextStyle(
                                                            fontSize: 11,
                                                            color: AppColors.onSurfaceVariant,
                                                        ),

                                                        textAlign: TextAlign.center,
                                                    ),
                                                ),

                                                const SizedBox(height: 24),
                                            ],
                                        ),
                                    ),
                                ),
                            ),
                        );
                    },
                ),
            ),
        );
    }
}


class _FieldLabel extends StatelessWidget {
    final String label;
    const _FieldLabel({required this.label});

    @override
    Widget build(BuildContext context) {
        return Text(
            label,
            style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
                color: AppColors.onSurfaceVariant,
            ),
        );
    }
}


class _InputField extends StatelessWidget {
    final TextEditingController controller;
    final FocusNode focusNode;
    final FocusNode? nextFocus;
    final String hintText;
    final TextInputType keyboardType;
    final bool obscureText;
    final IconData prefixIcon;
    final Widget? suffixIcon;
    final bool hasError;
    final bool isFocused;
    final String errorText;
    final ValueChanged<String>? onChanged;
    final ValueChanged<String>? onSubmitted;

    const _InputField({
        required this.controller,
        required this.focusNode,
        this.nextFocus,
        required this.hintText,
        this.keyboardType = TextInputType.text,
        this.obscureText = false,
        required this.prefixIcon,
        this.suffixIcon,
        required this.hasError,
        this.isFocused = false,
        required this.errorText,
        this.onChanged,
        this.onSubmitted,
    });

    @override
    Widget build(BuildContext context) {
        final borderColor = hasError
            ? AppColors.error
            : isFocused
                ? AppColors.primary
                : AppColors.outline;

        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        keyboardType: keyboardType,
                        obscureText: obscureText,
                        maxLength: 64,
                        onChanged: onChanged,
                        onSubmitted: onSubmitted ??
                            (nextFocus != null ? (_) => nextFocus!.requestFocus() : null),
                        textInputAction:
                            nextFocus != null ? TextInputAction.next : TextInputAction.done,

                        style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.onBackground,
                        ),

                        decoration: InputDecoration(
                            hintText: hintText,
                            hintStyle: const TextStyle(
                                color: AppColors.outline,
                                fontSize: 14,
                            ),
                            counterText: '',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 15,
                            ),

                            prefixIcon: Icon(
                                prefixIcon,
                                color: hasError
                                    ? AppColors.error
                                    : isFocused
                                        ? AppColors.primary
                                        : AppColors.onSurfaceVariant,
                                size: 20,
                            ),

                            suffixIcon: suffixIcon,
                        ),
                    ),
                ),

                if (hasError) Padding(
                    padding: const EdgeInsets.only(top: 5, left: 2),
                    child: Row(
                        children: [
                            const Icon(Icons.info_outline, size: 12, color: AppColors.error),
                            const SizedBox(width: 4),
                            Text(
                                errorText,
                                style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.error,
                                ),
                            ),
                        ],
                    ),
                ),
            ],
        );
    }
}


class _LoginButton extends StatelessWidget {
    final bool isLoading;
    final VoidCallback onPressed;

    const _LoginButton({required this.isLoading, required this.onPressed});

    @override
    Widget build(BuildContext context) {
        return SizedBox(
            width: double.infinity,
            height: 52,
            child: DecoratedBox(
                decoration: BoxDecoration(
                gradient: isLoading
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFFF56B39), Color(0xFFE04E20)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        ),
                color: isLoading ? AppColors.outline : null,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isLoading
                    ? []
                    : [
                        BoxShadow(
                            color: AppColors.primary.withValues(alpha: .30),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                        ),
                        ],
                ),
                child: ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.onSurfaceVariant),
                        ),
                        )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Text(
                            'Ingresar',
                            style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                            ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 17),
                        ],
                        ),
                ),
            ),
        );
    }
}