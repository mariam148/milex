import 'package:flutter/material.dart';

import '../widgets/auth_widgets.dart';
import '../widgets/password_reset_widgets.dart';

/// UI preview only. This screen has no authority to change credentials.
class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({super.key});
  @override
  State<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _visible = [false, false];

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.length < 8) {
      return 'Use at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Include an uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Include a lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Include a number';
    }
    return null;
  }

  Widget _field(
    int index,
    String label,
    TextEditingController controller,
  ) => TextFormField(
    controller: controller,
    obscureText: !_visible[index],
    autocorrect: false,
    enableSuggestions: false,
    keyboardType: TextInputType.visiblePassword,
    textInputAction: index == 0 ? TextInputAction.next : TextInputAction.done,
    decoration: authDecoration(
      label,
      prefix: const Icon(Icons.lock_outline, color: authMuted, size: 20),
      suffix: IconButton(
        tooltip: '${_visible[index] ? 'Hide' : 'Show'} ${label.toLowerCase()}',
        onPressed: () => setState(() => _visible[index] = !_visible[index]),
        icon: Icon(
          _visible[index]
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: authMuted,
        ),
      ),
    ),
    validator: index == 0
        ? _validatePassword
        : (value) {
            if (value == null || value.isEmpty) {
              return 'Confirm your new password';
            }
            if (value != _password.text) {
              return 'Passwords must match';
            }
            return null;
          },
  );

  @override
  Widget build(BuildContext context) => PasswordResetLayout(
    icon: Icons.lock_outline,
    title: 'Create new password',
    subtitle: 'Your new password must be different from your previous one.',
    children: [
      Form(
        key: _form,
        child: Column(
          children: [
            _field(0, 'New Password', _password),
            const SizedBox(height: 16),
            _field(1, 'Confirm Password', _confirm),
          ],
        ),
      ),
      const SizedBox(height: 28),
      const ResetContinueButton(),
      TextButton(
        onPressed: () {
          if (!_form.currentState!.validate()) {
            return;
          }
          FocusScope.of(context).unfocus();
          Navigator.of(context).pop(true);
        },
        child: const Text(
          'Demo: validate and return to Login',
          style: TextStyle(color: resetPurple),
        ),
      ),
    ],
  );
}
