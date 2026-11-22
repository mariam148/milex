import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const authPurple = Color(0xFF6036FF);
const authMuted = Color(0xFF8B8B98);

bool isValidMobileNumber(String digits, String countryCode) =>
    switch (countryCode) {
      '+20' => RegExp(r'^0?1[0125][0-9]{8}$').hasMatch(digits),
      '+966' || '+971' => RegExp(r'^0?5[0-9]{8}$').hasMatch(digits),
      _ => false,
    };

InputDecoration authDecoration(String hint, {Widget? prefix, Widget? suffix}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(7),
    borderSide: const BorderSide(color: Color(0xFF414151)),
  );
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: authMuted, fontSize: 16),
    prefixIcon: prefix,
    suffixIcon: suffix,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: const BorderSide(color: authPurple),
    ),
    errorMaxLines: 3,
  );
}

class AuthPhoneField extends StatelessWidget {
  const AuthPhoneField({
    super.key,
    required this.controller,
    required this.code,
    required this.onChanged,
  });
  final TextEditingController controller;
  final String code;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      IntrinsicWidth(
        child: DropdownButtonFormField<String>(
          initialValue: code,
          decoration: authDecoration(''),
          dropdownColor: const Color(0xFF171727),
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          items: const [
            DropdownMenuItem(value: '+20', child: Text('🇪🇬 +20')),
            DropdownMenuItem(value: '+966', child: Text('🇸🇦 +966')),
            DropdownMenuItem(value: '+971', child: Text('🇦🇪 +971')),
          ],
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.telephoneNumberNational],
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          decoration: authDecoration('Phone Number'),
          validator: (value) {
            final digits = value ?? '';
            final valid = isValidMobileNumber(digits, code);
            return valid ? null : 'Enter a valid mobile number';
          },
        ),
      ),
    ],
  );
}

class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key});
  @override
  Widget build(BuildContext context) => ShaderMask(
    shaderCallback: (rect) => const SweepGradient(
      colors: [
        Color(0xFF4285F4),
        Color(0xFF34A853),
        Color(0xFFFBBC05),
        Color(0xFFEA4335),
        Color(0xFF4285F4),
      ],
    ).createShader(rect),
    child: const Text(
      'G',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w900,
        fontSize: 24,
      ),
    ),
  );
}
