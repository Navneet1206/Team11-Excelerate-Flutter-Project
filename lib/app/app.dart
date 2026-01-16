import 'package:flutter/material.dart';

import '../screens/home/home_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/programs/program_detail_screen.dart';
import '../screens/programs/program_list_screen.dart';
import '../theme/app_theme.dart';
import 'routes.dart';

class SkillTrackApp extends StatelessWidget {
  const SkillTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillTrack Pro',
      theme: AppTheme.light(),
      initialRoute: Routes.login,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case Routes.login:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case Routes.home:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case Routes.programList:
            return MaterialPageRoute(builder: (_) => const ProgramListScreen());
          case Routes.programDetails:
            return MaterialPageRoute(builder: (_) => const ProgramDetailScreen());
          default:
            return MaterialPageRoute(
              builder: (_) => const _RouteErrorScreen(),
            );
        }
      },
    );
  }
}

class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Route not found / invalid arguments.'),
      ),
    );
  }
}
