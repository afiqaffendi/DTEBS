import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:dtebs/core/theme/app_theme.dart';
import 'package:dtebs/features/auth/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const DtebsApp());
}

class DtebsApp extends StatelessWidget {
  const DtebsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DTEBS',
      themeMode: ThemeMode.light,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
