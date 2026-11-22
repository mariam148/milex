import 'package:flutter/material.dart';

import '../widgets/onboarding_widgets.dart';

class OnboardingCompletionScreen extends StatelessWidget {
  const OnboardingCompletionScreen({super.key});
  @override
  Widget build(BuildContext context) => OnboardingLayout(
    step: 3,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.task_alt, size: 72, color: milexPurple),
        const SizedBox(height: 24),
        const OnboardingTitle(
          title: 'Demo onboarding complete',
          subtitle: 'Development preview only. No account has been created. Your details and photos remain in memory for this session; nothing has been uploaded or verified.',
        ),
        const Text(
          'Registration, secure document upload and authenticated Home navigation still require backend integration.',
          style: TextStyle(color: milexMuted),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Review address'),
        ),
      ],
    ),
  );
}
