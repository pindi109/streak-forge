
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey          = GlobalKey<FormState>();
  final _nameCtrl         = TextEditingController();
  final _emailCtrl        = TextEditingController();
  final _passwordCtrl     = TextEditingController();
  final _confirmPassCtrl  = TextEditingController();
  bool _obscurePassword   = true;
  bool _obscureConfirm    = true;
  bool _agreedToTerms     = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: AppConstants.animSlow,
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  // ── Handlers ──────────────────────────────────────────────────────────────────

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreedToTerms) {
      _showError('Please agree to the Terms of Service to continue.');
      return;
    }
    final auth = context.read<AuthProvider>();
    await auth.registerWithEmail(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      displayName: _nameCtrl.text.trim(),
    );
    if (mounted && auth.errorMessage != null) {
      _showError(auth.errorMessage!);
    }
  }

  Future<void> _handleGoogleRegister() async {
    final auth = context.read<AuthProvider>();
    await auth.signInWithGoogle();
    if (mounted && auth.errorMessage != null) {
      _showError(auth.errorMessage!);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        duration: AppConstants.snackDuration,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return Stack(
            children: [
              _buildBackground(),
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingLG,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            _buildBackButton(),
                            const SizedBox(height: 24),
                            _buildHeader(),
                            const SizedBox(height: 40),
                            _buildNameField(),
                            const SizedBox(height: 16),
                            _buildEmailField(),
                            const SizedBox(height: 16),
                            _buildPasswordField(),
                            const SizedBox(height: 16),
                            _buildConfirmPasswordField(),
                            const SizedBox(height: 20),
                            _buildTermsCheckbox(),
                            const SizedBox(height: 28),
                            _buildRegisterButton(auth.isLoading),
                            const SizedBox(height: 24),
                            _buildDivider(),
                            const SizedBox(height: 24),
                            _buildGoogleButton(auth.isLoading),
                            const SizedBox(height: 32),
                            _buildLoginPrompt(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (auth.isLoading) const LoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.gradientEnd.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primary.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.local_fire_department_rounded,
              color: Colors.white, size: 32),
        ),
        const SizedBox(height: 24),
        const Text('Create account', style: AppTheme.headingLarge),
        const SizedBox(height: 8),
        const Text(
          'Start building better habits today',
          style: AppTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameCtrl,
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      style: AppTheme.bodyLarge,
      decoration: const InputDecoration(
        labelText: 'Full Name',
        hintText: 'John Doe',
        prefixIcon: Icon(Icons.person_outline_rounded),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return AppConstants.errRequired;
        if (v.trim().length < 2) return 'Name must be at least 2 characters';
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      style: AppTheme.bodyLarge,
      decoration: const InputDecoration(
        labelText: 'Email',
        hintText: 'you@example.com',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return AppConstants.errRequired;
        if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v)) {
          return AppConstants.errEmailInvalid;
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordCtrl,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      style: AppTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: '••••••••',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return AppConstants.errRequired;
        if (v.length < 6) return AppConstants.errPasswordShort;
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPassCtrl,
      obscureText: _obscureConfirm,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleRegister(),
      style: AppTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        hintText: '••••••••',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirm
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () =>
              setState(() => _obscureConfirm = !_obscureConfirm),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return AppConstants.errRequired;
        if (v != _passwordCtrl.text) return AppConstants.errPasswordMatch;
        return null;
      },
    );
  }

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: AppConstants.animFast,
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _agreedToTerms ? AppTheme.primary : Colors.transparent,
              border: Border.all(
                color: _agreedToTerms ? AppTheme.primary : AppTheme.border,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: _agreedToTerms
                ? const Icon(Icons.check, size: 13, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
                children: [
                  TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(bool isLoading) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          ),
        ),
        child: const Text(
          'Create Account',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppTheme.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or sign up with',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ),
        const Expanded(child: Divider(color: AppTheme.border)),
      ],
    );
  }

  Widget _buildGoogleButton(bool isLoading) {
    return OutlinedButton(
      onPressed: isLoading ? null : _handleGoogleRegister,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppTheme.border),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        ),
        backgroundColor: AppTheme.surface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.g_mobiledata_rounded,
              color: AppTheme.textPrimary, size: 24),
          const SizedBox(width: 12),
          const Text(
            'Continue with Google',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Already have an account? ', style: AppTheme.bodyMedium),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Sign In',
            style: TextStyle(
              color: AppTheme.primaryLight,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}