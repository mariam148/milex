import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/password_reset_widgets.dart';
import 'create_new_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    this.phoneNumber = '',
    this.countryCode = '+20',
  });
  final String phoneNumber;
  final String countryCode;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _digits = List.generate(4, (_) => TextEditingController());
  final _focus = List.generate(4, (_) => FocusNode());
  String? _error;

  String get _maskedPhone {
    final digits = widget.phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return 'No phone number entered on Login';
    }
    final visible = digits.length > 2
        ? digits.substring(digits.length - 2)
        : '';
    return '${widget.countryCode}${List.filled(digits.length - visible.length, '*').join()}$visible';
  }

  void _changed(int index, String value) {
    setState(() => _error = null);
    if (value.length > 1) {
      // A full OTP pasted into any box replaces the entire code.
      final start = value.length == 4 ? 0 : index;
      var target = start;
      for (final digit in value.split('')) {
        if (target == 4) {
          break;
        }
        _digits[target++].text = digit;
      }
      _focus[target < 4 ? target : 3].requestFocus();
    } else if (value.isNotEmpty && index < 3) {
      _focus[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focus[index - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    for (final controller in _digits) {
      controller.dispose();
    }
    for (final node in _focus) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PasswordResetLayout(
    icon: Icons.verified_user_outlined,
    title: 'Enter verification code',
    subtitle: 'Demo code preview for: $_maskedPhone',
    children: [
      Row(
        children: List.generate(
          4,
          (index) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index < 3 ? 12 : 0),
              child: Focus(
                onKeyEvent: (_, event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.backspace &&
                      _digits[index].text.isEmpty &&
                      index > 0) {
                    _focus[index - 1].requestFocus();
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: TextField(
                  key: ValueKey('otp-$index'),
                  controller: _digits[index],
                  focusNode: _focus[index],
                  autofocus: index == 0,
                  keyboardType: TextInputType.number,
                  textInputAction: index == 3
                      ? TextInputAction.done
                      : TextInputAction.next,
                  autofillHints: index == 0
                      ? const [AutofillHints.oneTimeCode]
                      : null,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                  decoration: InputDecoration(
                    counterText: '',
                    semanticCounterText: 'Verification digit ${index + 1} of 4',
                    filled: true,
                    fillColor: const Color(0xFF101024),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: resetPurple),
                    ),
                  ),
                  onChanged: (value) => _changed(index, value),
                ),
              ),
            ),
          ),
        ),
      ),
      if (_error != null)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      const SizedBox(height: 28),
      const ResetContinueButton(),
      const SizedBox(height: 20),
      const Text(
        "Didn't receive the OTP?",
        style: TextStyle(color: Colors.white70),
      ),
      const TextButton(onPressed: null, child: Text('Resend')),
      const Text(
        'Resend is unavailable in Demo Mode. No OTP is sent.',
        style: TextStyle(color: Colors.white54, fontSize: 12),
      ),
      TextButton(
        onPressed: () async {
          if (!_digits.every((digit) => RegExp(r'^\d$').hasMatch(digit.text))) {
            setState(
              () => _error =
                  'Enter exactly four digits to preview the next screen.',
            );
            return;
          }
          FocusScope.of(context).unfocus();
          final returnToLogin = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const CreateNewPasswordScreen()),
          );
          if (returnToLogin == true && context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: const Text(
          'Demo: preview new password',
          style: TextStyle(color: resetPurple),
        ),
      ),
    ],
  );
}
