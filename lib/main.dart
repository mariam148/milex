import 'package:flutter/material.dart';

import 'screens/sign_up_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MileXApp());
}

class MileXApp extends StatelessWidget {
  const MileXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MileX',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF050519),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6036FF),
          brightness: Brightness.dark,
        ),
      ),
      home: const SignUpScreen(),
    );
  }
}
