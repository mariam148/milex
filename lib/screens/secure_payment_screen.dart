import 'package:flutter/material.dart';

import '../models/booking_model.dart';
import '../services/demo_session.dart';
import '../widgets/demo_widgets.dart';
import 'booking_confirmed_screen.dart';

class SecurePaymentScreen extends StatefulWidget {
  const SecurePaymentScreen({
    super.key,
    required this.draft,
    required this.session,
  });
  final BookingDraft draft;
  final DemoSession session;
  @override
  State<SecurePaymentScreen> createState() => _SecurePaymentScreenState();
}

class _SecurePaymentScreenState extends State<SecurePaymentScreen> {
  bool _agree = false, _confirming = false;
  final _confirmationKey = Object();
  void _confirm() {
    if (!_agree || _confirming) return;
    setState(() => _confirming = true);
    final booking = widget.session.bookings.confirm(
      widget.draft,
      _confirmationKey,
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) =>
            BookingConfirmedScreen(booking: booking, session: widget.session),
      ),
      (route) => route.isFirst,
    );
  }

  Widget _dummy(String label, String value, {bool obscure = false}) =>
      TextField(
        readOnly: true,
        enabled: false,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          hintText: value,
          border: const OutlineInputBorder(),
        ),
      );
  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'Secure Payment',
    footer: DemoAction(
      'Pay Securely (Demo)',
      onPressed: _agree && !_confirming ? _confirm : null,
    ),
    children: [
      const DemoNotice(
        'Demo payment - no money will be charged. Do not enter real card information. All fields below are non-editable dummy labels.',
      ),
      DemoPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.credit_card, color: demoPurple, size: 44),
            Text(
              widget.draft.paymentMethod,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _dummy('Cardholder name', 'MILEX DEMO USER'),
            const SizedBox(height: 12),
            _dummy('Card number', 'DEMO / NOT A REAL CARD'),
            const SizedBox(height: 12),
            _dummy('Expiration date', 'MM / YY (dummy)'),
            const SizedBox(height: 12),
            _dummy('CVV', 'Not collected'),
          ],
        ),
      ),
      Text(
        widget.draft.car.name,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      DemoPriceBreakdown(widget.draft),
      Material(
        color: Colors.transparent,
        child: CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          key: const ValueKey('demo-payment-consent'),
          value: _agree,
          title: const Text(
            'I understand this creates only a local demo booking.',
          ),
          onChanged: _confirming
              ? null
              : (value) => setState(() => _agree = value ?? false),
        ),
      ),
    ],
  );
}
