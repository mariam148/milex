import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/auth_widgets.dart';
import 'forgot_password_screen.dart';
import 'sign_up_screen.dart';

import '../auth/auth_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  String _code = '+20';
  bool _visible = false;
  bool _remember = false;
  bool _preferenceReady = false;
  bool _saving = false;
  bool _openingHome = false;

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _remember = prefs.getBool('remember_me') ?? false;
        });
      }
    } catch (_) {
      if (mounted) _message('Could not load Remember Me preference.');
    } finally {
      if (mounted) setState(() => _preferenceReady = true);
    }
  }

  Future<void> _setRemember(bool value) async {
    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setBool('remember_me', value)) {
        throw StateError('Save failed');
      }

      if (mounted) setState(() => _remember = value);
    } catch (_) {
      if (mounted) _message('Could not save Remember Me. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _login() async {
    if (_openingHome || !_form.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    _password.clear();
    setState(() => _openingHome = true);
    await DemoNavigation.openHome(context);
    if (mounted) {
      setState(() => _openingHome = false);
    }
  }

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Widget _social(String provider, Widget icon) => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: () =>
          _message('Google Sign-In is not available in Demo Mode.'),
      icon: icon,
      label: Text('Continue with $provider'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF2F2F4),
        foregroundColor: Colors.black,
        minimumSize: const Size(0, 48),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF050519),
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
                  vertical: 48,
                ),
                child: AutofillGroup(
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Ready to hit the road?',
                          style: TextStyle(fontSize: 14, color: authMuted),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Development-only demo login. No real account or authenticated session. Remember Me saves only this checkbox preference.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: authMuted, fontSize: 12),
                        ),
                        const SizedBox(height: 20),
                        AuthPhoneField(
                          controller: _phone,
                          code: _code,
                          onChanged: (value) => setState(() => _code = value),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _password,
                          obscureText: !_visible,
                          enableSuggestions: false,
                          autocorrect: false,
                          autofillHints: const [AutofillHints.password],
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _login(),
                          decoration: authDecoration(
                            'Password',
                            prefix: const Icon(
                              Icons.lock_outline,
                              color: authMuted,
                              size: 20,
                            ),
                            suffix: IconButton(
                              tooltip: _visible
                                  ? 'Hide password'
                                  : 'Show password',
                              onPressed: () =>
                                  setState(() => _visible = !_visible),
                              icon: Icon(
                                _visible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: authMuted,
                              ),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter your password'
                              : value.length < 8
                              ? 'Use at least 8 characters'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Checkbox(
                              value: _remember,
                              activeColor: authPurple,
                              onChanged: _preferenceReady && !_saving
                                  ? (value) => _setRemember(value!)
                                  : null,
                              visualDensity: VisualDensity.compact,
                            ),
                            const Flexible(
                              child: Text(
                                'Remember Me',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            const Spacer(),
                            Flexible(
                              child: TextButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => ForgotPasswordScreen(
                                      phoneNumber: _phone.text,
                                      countryCode: _code,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: authPurple,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _openingHome || !_preferenceReady || _saving
                                ? null
                                : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: authPurple,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 48),
                            ),
                            child: _openingHome
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Demo Login',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Row(
                          children: [
                            Expanded(child: Divider(color: Color(0xFF414151))),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 17),
                              child: Text(
                                'Or',
                                style: TextStyle(color: authMuted),
                              ),
                            ),
                            Expanded(child: Divider(color: Color(0xFF414151))),
                          ],
                        ),
                        const SizedBox(height: 19),
                        _social('Google', const GoogleLogo()),
                        const SizedBox(height: 23),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(color: authMuted, fontSize: 14),
                            ),
                            TextButton(
                              onPressed: () {
                                if (Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                } else {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const SignUpScreen(),
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                'Sign Up.',
                                style: TextStyle(color: authPurple),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
