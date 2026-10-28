import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

enum AppButtonStyle { primary, outlined }

class AppButton extends StatelessWidget {
  const AppButton(
      {super.key,
      required this.title,
      required this.onPressed,
      this.isLoading = false,
      this.icon,
      this.style = AppButtonStyle.primary,
      this.isExpanded = true});

  final String title;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final AppButtonStyle style;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final child = SizedBox(
        height: 54,
        child: style == AppButtonStyle.primary
            ? ElevatedButton(onPressed: isLoading ? null : onPressed, child: _content())
            : OutlinedButton(
                onPressed: isLoading ? null : onPressed,
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: _content()));
    return isExpanded ? SizedBox(width: double.infinity, child: child) : child;
  }

  Widget _content() {
    if (isLoading)
      return const SizedBox(
          height: 21, width: 21, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white));
    return Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
      if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
      Text(title)
    ]);
  }
}
