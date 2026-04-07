import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final Widget? icon;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.height = 54,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppTheme.primary,
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: onPressed != null
                    ? AppTheme.primaryGradient
                    : LinearGradient(
                        colors: [
                          AppTheme.primary.withOpacity(0.5),
                          AppTheme.gradientEnd.withOpacity(0.5),
                        ],
                      ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...
                      [icon!, const SizedBox(width: 8)],
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
