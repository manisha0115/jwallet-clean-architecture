import 'package:flutter/material.dart';

class AppStateView extends StatelessWidget {
  const AppStateView(
      {super.key,
      required this.title,
      required this.message,
      this.icon = Icons.info_outline_rounded,
      this.actionLabel,
      this.onAction});

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 44, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            if (actionLabel != null && onAction != null) TextButton(onPressed: onAction, child: Text(actionLabel!))
          ])));
}
