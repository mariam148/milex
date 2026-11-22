import 'package:flutter/material.dart';

import '../models/onboarding_data.dart';
import 'profile_photo_screen.dart';
import 'login_screen.dart';

import '../auth/auth_navigation.dart';

import '../widgets/auth_widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  static const Color background = Color(0xFF050519);
  static const Color purple = Color(0xFF6036FF);
  static const Color inputBorder = Color(0xFF414151);
  static const Color hintColor = Color(0xFF8B8B98);

  final _formKey = GlobalKey<FormState>();
  final _onboardingData = OnboardingData();
  bool _openingOnboarding = false;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool showPassword = false;
  String countryCode = '+20';
  String? country;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration inputDecoration(
    String hint,
    IconData icon, {
    Widget? suffix,
    bool showIcon = true,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: hintColor, fontSize: 16),
      prefixIcon: showIcon ? Icon(icon, color: hintColor, size: 20) : null,
      suffixIcon: suffix,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: inputBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: purple, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
    );
  }

  Widget socialButton({
    required String label,
    required Widget icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 43,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF2F2F4),
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  Future<void> signUp() async {
    if (_openingOnboarding) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _onboardingData.fullName = nameController.text.trim();
    _onboardingData.phoneNumber = '$countryCode${phoneController.text.trim()}';
    _onboardingData.country = country;
    DemoNavigation.rememberDraft(_onboardingData);
    passwordController.clear();
    FocusScope.of(context).unfocus();
    setState(() => _openingOnboarding = true);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfilePhotoScreen(data: _onboardingData),
      ),
    );
    if (mounted) setState(() => _openingOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 72),

                        // SIGN UP TITLE
                        const Text(
                          'Sign Up',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Create your account to start booking.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: hintColor, fontSize: 15),
                        ),

                        const SizedBox(height: 29),

                        // FULL NAME
                        TextFormField(
                          controller: nameController,
                          textCapitalization: TextCapitalization.words,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: inputDecoration(
                            'Full Name',
                            Icons.person_outline,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 11),

                        // PHONE COUNTRY CODE + PHONE NUMBER
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 125,
                              child: DropdownButtonFormField<String>(
                                initialValue: countryCode,
                                isExpanded: true,
                                dropdownColor: const Color(0xFF171727),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 18,
                                  color: Colors.white70,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 15,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: const BorderSide(
                                      color: inputBorder,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                    borderSide: const BorderSide(color: purple),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: '+20',
                                    child: Text('🇪🇬 +20'),
                                  ),
                                  DropdownMenuItem(
                                    value: '+966',
                                    child: Text('🇸🇦 +966'),
                                  ),
                                  DropdownMenuItem(
                                    value: '+971',
                                    child: Text('🇦🇪 +971'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      countryCode = value;
                                    });
                                  }
                                },
                              ),
                            ),

                            const SizedBox(width: 6),

                            Expanded(
                              child: TextFormField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                decoration: inputDecoration(
                                  'Phone Number',
                                  Icons.phone,
                                  showIcon: false,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter phone number';
                                  }
                                  if (!isValidMobileNumber(
                                    value.trim(),
                                    countryCode,
                                  )) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 11),

                        // PASSWORD
                        TextFormField(
                          controller: passwordController,
                          obscureText: !showPassword,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: inputDecoration(
                            'Password',
                            Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                showPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: hintColor,
                                size: 21,
                              ),
                              onPressed: () {
                                setState(() {
                                  showPassword = !showPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 8) {
                              return 'Use at least 8 characters';
                            }
                            if (!RegExp(r'[A-Z]').hasMatch(value) ||
                                !RegExp(r'[a-z]').hasMatch(value) ||
                                !RegExp(r'[0-9]').hasMatch(value)) {
                              return 'Use uppercase, lowercase and a number';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 11),

                        // COUNTRY
                        DropdownButtonFormField<String>(
                          initialValue: country,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF171727),
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: hintColor,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          hint: const Text(
                            'Country',
                            style: TextStyle(color: hintColor, fontSize: 16),
                          ),
                          decoration: inputDecoration('', Icons.language),
                          items: const [
                            DropdownMenuItem(
                              value: 'Egypt',
                              child: Text('Egypt'),
                            ),
                            DropdownMenuItem(
                              value: 'Saudi Arabia',
                              child: Text('Saudi Arabia'),
                            ),
                            DropdownMenuItem(value: 'UAE', child: Text('UAE')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              country = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a country';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 19),

                        // SIGN UP BUTTON
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            'LOCAL DEMO MODE: Preview onboarding. No real account is created.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: hintColor, fontSize: 12),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 47,
                          child: ElevatedButton(
                            onPressed: _openingOnboarding ? null : signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: purple,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // OR DIVIDER
                        const Row(
                          children: [
                            Expanded(
                              child: Divider(color: inputBorder, thickness: 1),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 17),
                              child: Text(
                                'Or',
                                style: TextStyle(
                                  color: hintColor,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: inputBorder, thickness: 1),
                            ),
                          ],
                        ),

                        const SizedBox(height: 19),

                        // GOOGLE BUTTON
                        socialButton(
                          label: 'Continue with Google',
                          icon: const GoogleLogo(),
                          onPressed: _openingOnboarding
                              ? null
                              : () => ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Google Sign-In is not available in Demo Mode.',
                                        ),
                                      ),
                                    ),
                        ),

                        const SizedBox(height: 23),

                        // LOGIN
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: TextStyle(color: hintColor, fontSize: 14),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Log In.',
                                style: TextStyle(
                                  color: purple,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
