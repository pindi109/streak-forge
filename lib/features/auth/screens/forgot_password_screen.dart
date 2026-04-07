import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AppAuthProvider>();
    final success =
        await auth.sendPasswordResetEmail(_emailController.text);
    if (success && mounted) {
      setState(() => _emailSent = true);
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Failed to send reset email'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _emailSent ? _buildSuccessState() : _buildForm(auth),
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_read_outlined,
                color: AppTheme.success, size: 40),
          ),
          const SizedBox(height: 24),
          const Text('Email Sent!',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text(
            'We sent a reset link to ${_emailController.text}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Sign In'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(AppAuthProvider auth) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text('Forgot your password?',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          const Text(
            'Enter your email address and we\'ll send you a link to reset your password.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 36),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Email address',
              prefixIcon: Icon(Icons.email_outlined,
                  color: AppTheme.textSecondary, size: 20),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Email is required';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$')
                  .hasMatch(val)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: auth.isLoading
                ? const LoadingWidget()
                : Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: _handleReset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Send Reset Link',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
