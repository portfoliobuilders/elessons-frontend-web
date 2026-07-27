import 'package:flutter/material.dart';

/// Authentication Screen Footer (Prompt + Clickable Action Link).
class AuthFooter extends StatelessWidget {
  const AuthFooter({
    super.key,
    required this.promptText,
    required this.actionText,
    required this.onActionTap,
  });

  final String promptText;
  final String actionText;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          promptText,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF777777),
          ),
        ),
        const SizedBox(width: 6),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
