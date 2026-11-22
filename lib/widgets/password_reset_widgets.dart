import 'package:flutter/material.dart';

import 'auth_widgets.dart';

const resetPurple = Color(0xFF6947FF);

/// Shared, scrollable layout for the development-only recovery preview.
class PasswordResetLayout extends StatelessWidget {
  const PasswordResetLayout({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF050519),
    appBar: AppBar(backgroundColor: const Color(0xFF050519)),
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 460),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF15142C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(icon, color: resetPurple, size: 40),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: authMuted,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    ...children,
                    const SizedBox(height: 20),
                    const Text(
                      'DEVELOPMENT-ONLY PREVIEW\nAuthentication is not connected. No code has been sent and no password will be changed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: authMuted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class ResetContinueButton extends StatelessWidget {
  const ResetContinueButton({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: resetPurple.withValues(alpha: .45),
        disabledForegroundColor: Colors.white70,
        minimumSize: const Size(0, 52),
        shape: const StadiumBorder(),
      ),
      child: const Text(
        'Continue',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
