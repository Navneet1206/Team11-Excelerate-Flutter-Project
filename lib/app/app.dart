import 'package:flutter/material.dart';

import '../screens/login/login_screen.dart';
import '../theme/app_theme.dart';


class SkillTrackApp extends StatelessWidget {
  const SkillTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}

