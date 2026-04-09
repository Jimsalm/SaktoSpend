import 'package:flutter/material.dart';

class AppSnackbars {
  const AppSnackbars._();

  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    _show(
      context,
      message,
      backgroundColor: const Color(0xFF1F3B2A),
      borderColor: const Color(0xFF2E5A40),
      icon: Icons.check_circle_outline,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    _show(
      context,
      message,
      backgroundColor: const Color(0xFF4D1E1E),
      borderColor: const Color(0xFF7A2727),
      icon: Icons.error_outline,
      duration: duration,
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required Color borderColor,
    required IconData icon,
    Duration? duration,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: duration ?? const Duration(seconds: 2),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor),
        ),
        content: Row(
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
