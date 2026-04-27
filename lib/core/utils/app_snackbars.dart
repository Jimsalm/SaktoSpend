import 'package:SaktoSpend/core/theme/app_theme.dart';
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
      icon: Icons.check_circle_outline,
      iconColor: context.appThemeTokens.accentInk,
      iconBackgroundColor: context.appThemeTokens.accentSoft,
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
      icon: Icons.error_outline,
      iconColor: context.appThemeTokens.warningStrong,
      iconBackgroundColor: context.appThemeTokens.warningSoft,
      duration: duration,
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required IconData icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    Duration? duration,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }
    final theme = Theme.of(context);
    final tokens = context.appThemeTokens;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: duration ?? const Duration(seconds: 2),
        backgroundColor: tokens.surfacePrimary,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        elevation: 0,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: tokens.borderSubtle),
        ),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.snackBarTheme.contentTextStyle?.copyWith(
                  color: tokens.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
