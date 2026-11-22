
import 'package:flutter/material.dart';

import '../auth/auth_navigation.dart';
import '../services/demo_session.dart';
import '../widgets/demo_widgets.dart';
import 'drivers_license_screen.dart';
import 'my_bookings_screen.dart';
import 'profile_settings_screen.dart';
import 'support_screen.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key, required this.session});

  final DemoSession session;

  void _open(BuildContext context, Widget screen) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => screen));

  Widget _row(
    BuildContext context,
    String label,
    IconData icon,
    Widget screen,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Material(
      color: const Color(0xFF101929),
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        minTileHeight: 48,
        leading: Icon(
          icon,
          color: const Color(0xFFAA97FF),
          size: 19,
        ),
        title: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF949BAD),
          size: 19,
        ),
        onTap: () => _open(context, screen),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: session,
    builder: (context, _) {
      final data = session.profile;
      final settings = ProfileSettingsScreen(session: session);
      final edit = ProfileSettingsScreen(
        session: session,
        editProfile: true,
      );

      final name = data.fullName.trim().isEmpty
          ? 'Demo driver'
          : data.fullName.trim();

      final initials = name
          .split(RegExp(r'\s+'))
          .take(2)
          .map((part) => part.characters.first)
          .join()
          .toUpperCase();

      return ColoredBox(
        color: const Color(0xFF080D1B),
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'My Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Profile Header
                    Material(
                      color: const Color(0xFF101929),
                      borderRadius: BorderRadius.circular(18),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _open(context, edit),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 24,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: const Color(0xFF6B4CFA),
                                backgroundImage: data.profilePhoto == null
                                    ? null
                                    : MemoryImage(data.profilePhoto!),
                                child: data.profilePhoto == null
                                    ? Text(
                                        initials,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                    : null,
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      data.phoneNumber.isEmpty
                                          ? 'Local demo profile'
                                          : data.phoneNumber,
                                      style: const TextStyle(
                                        color: Color(0xFF949BAD),
                                        fontSize: 12,
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    const Row(
                                      children: [
                                        Text(
                                          'Edit Profile',
                                          style: TextStyle(
                                            color: Color(0xFFAA97FF),
                                            fontSize: 12,
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: Color(0xFFAA97FF),
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Driver Verification
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D2742),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            color: Color(0xFFAA97FF),
                            size: 21,
                          ),

                          SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Driver verification pending',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                SizedBox(height: 5),

                                Text(
                                  'Complete your profile to book cars',
                                  style: TextStyle(
                                    color: Color(0xFF949BAD),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Account Section
                    const Text(
                      'Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 14),

                    _row(
                      context,
                      'Personal Information',
                      Icons.person_outline,
                      edit,
                    ),

                    // Driver's License
                    _row(
                      context,
                      "Driver's License",
                      Icons.badge_outlined,
                      DemoPage(
                        title: "Driver's License",
                        children: [
                          const DemoNotice(
                            'Local, unverified license draft. Nothing has been uploaded.',
                          ),

                          Text(
                            data.licenseNumber.isEmpty
                                ? 'No license details entered.'
                                : 'License: ${data.licenseNumber}',
                          ),

                          Text(
                            'Issuing country: ${data.issuingCountry ?? 'Not entered'}',
                          ),

                          Text(
                            'Front photo: ${data.licenseFront == null ? 'Not added' : 'In-memory draft'}',
                          ),

                          Text(
                            'Back photo: ${data.licenseBack == null ? 'Not added' : 'In-memory draft'}',
                          ),

                          // Edit License Icon
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              tooltip: 'Edit license draft',
                              icon: const Icon(Icons.edit_outlined),
                              color: const Color(0xFFAA97FF),
                              iconSize: 24,
                              onPressed: () => _open(
                                context,
                                DriversLicenseScreen(data: data),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // My Bookings
                    _row(
                      context,
                      'My Bookings',
                      Icons.calendar_month_outlined,
                      MyBookingsScreen(session: session),
                    ),

                    // Payment Methods
                    _row(
                      context,
                      'Payment Methods',
                      Icons.credit_card_outlined,
                      const DemoPage(
                        title: 'Payment Methods',
                        children: [
                          DemoNotice(
                            'Dummy payment labels only. No real card information is collected or saved.',
                          ),

                          DemoPanel(
                            child: ListTile(
                              leading: Icon(Icons.credit_card),
                              title: Text('Visa demo'),
                              subtitle: Text('No card on file'),
                            ),
                          ),

                          DemoPanel(
                            child: ListTile(
                              leading: Icon(Icons.credit_card),
                              title: Text('Mastercard demo'),
                              subtitle: Text('No card on file'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Saved Locations
                    _row(
                      context,
                      'Saved Locations',
                      Icons.location_on_outlined,
                      ListenableBuilder(
                        listenable: session,
                        builder: (context, _) {
                          final profile = session.profile;

                          final address = [
                            profile.country,
                            profile.city,
                            profile.district,
                            profile.street,
                            profile.building,
                          ]
                              .whereType<String>()
                              .where((v) => v.isNotEmpty)
                              .join(', ');

                          return DemoPage(
                            title: 'Saved Locations',
                            children: [
                              const DemoNotice(
                                'Local address draft only. No location service is used.',
                              ),

                              Text(
                                address.isEmpty
                                    ? 'No local address saved.'
                                    : address,
                              ),

                              DemoAction(
                                'Edit local location',
                                onPressed: () => _open(context, edit),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // Notifications
                    _row(
                      context,
                      'Notifications',
                      Icons.notifications_outlined,
                      settings,
                    ),

                    // Help & Support
                    _row(
                      context,
                      'Help & Support',
                      Icons.headset_mic_outlined,
                      SupportScreen(session: session),
                    ),

                    // Settings
                    _row(
                      context,
                      'Settings',
                      Icons.settings_outlined,
                      settings,
                    ),

                    // Logout
                    TextButton(
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Color(0xFF949BAD),
                        ),
                      ),
                      onPressed: () =>
                          DemoNavigation.logout(context, session),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
