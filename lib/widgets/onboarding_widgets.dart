import 'package:flutter/material.dart';

const milexPurple = Color(0xFF6947FF);
const milexMuted = Color(0xFFA6A3B5);
const onboardingCountries = {
  'Egypt': '🇪🇬',
  'Saudi Arabia': '🇸🇦',
  'UAE': '🇦🇪',
  'Jordan': '🇯🇴',
  'United Kingdom': '🇬🇧',
  'United States': '🇺🇸',
  'Canada': '🇨🇦',
  'Germany': '🇩🇪',
  'France': '🇫🇷',
  'India': '🇮🇳',
};

class OnboardingLayout extends StatelessWidget {
  const OnboardingLayout({
    super.key,
    required this.child,
    required this.step,
    this.footer,
  });
  final Widget child;
  final int step;
  final Widget? footer;
  @override
  Widget build(BuildContext context) => Theme(
    data: ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: const Color(0xFF050509),
      colorScheme: ColorScheme.fromSeed(
        seedColor: milexPurple,
        brightness: Brightness.dark,
        primary: milexPurple,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF15131D),
        hintStyle: const TextStyle(color: Color(0xFF777181)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF34303E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: milexPurple, width: 1.5),
        ),
        errorMaxLines: 3,
      ),
    ),
    child: Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      ),
                      const Spacer(),
                      Image.asset(
                        'assets/images/milex_logo.png',
                        width: 64,
                        height: 64,
                        semanticLabel: 'MileX',
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        Semantics(
                          label: 'Step $step of 3',
                          child: Row(
                            children: List.generate(
                              3,
                              (index) => Expanded(
                                child: Container(
                                  height: 4,
                                  margin: EdgeInsets.only(
                                    right: index < 2 ? 8 : 0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: index < step
                                        ? milexPurple
                                        : const Color(0xFF292532),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        child,
                      ],
                    ),
                  ),
                ),
                if (footer != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                    child: footer!,
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class OnboardingContinueButton extends StatelessWidget {
  const OnboardingContinueButton({super.key, this.onPressed});
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: milexPurple,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 54),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    child: const Text(
      'Save and Continue',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  );
}

class OnboardingField extends StatelessWidget {
  const OnboardingField({super.key, required this.label, required this.child});
  final String label;
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: const TextStyle(color: milexMuted, fontSize: 13)),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );
}

class OnboardingCountryField extends StatelessWidget {
  const OnboardingCountryField({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final String? value;
  final ValueChanged<String?> onChanged;
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    initialValue: value,
    isExpanded: true,
    decoration: const InputDecoration(hintText: 'Select country'),
    items: onboardingCountries.entries
        .map(
          (entry) => DropdownMenuItem(
            value: entry.key,
            child: Text(
              '${entry.value} ${entry.key}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
        .toList(),
    onChanged: onChanged,
    validator: (value) => value == null ? 'Please select a country' : null,
  );
}

class GradientButton extends StatelessWidget {
  const GradientButton({super.key, required this.label, this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFAC78FF), Color(0xFF7139E9)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            minimumSize: const Size(double.infinity, 56),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: onPressed,
          child: Text(label, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

class OnboardingTitle extends StatelessWidget {
  const OnboardingTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        subtitle,
        style: const TextStyle(fontSize: 15, height: 1.6, color: milexMuted),
      ),
      const SizedBox(height: 28),
    ],
  );
}

void showUnavailable(BuildContext context, String feature) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '$feature is not available yet. You can continue with the form.',
      ),
    ),
  );
}
