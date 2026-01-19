import 'package:flutter/material.dart';

import '../app/routes.dart';
import '../screens/home/home_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/programs/program_detail_screen.dart';
import '../screens/programs/program_list_screen.dart';
import '../theme/app_theme.dart';

class SkillTrackApp extends StatelessWidget {
  const SkillTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: Routes.login,
      routes: {
        Routes.login: (_) => const LoginScreen(),
        Routes.home: (_) => const HomeScreen(),
        Routes.programList: (_) => const ProgramListScreen(),
        Routes.programDetails: (_) => const ProgramDetailScreen(),
      },
    );
  }
}
