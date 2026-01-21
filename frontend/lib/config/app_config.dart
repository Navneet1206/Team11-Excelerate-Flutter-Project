import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Global app configuration.
///
/// Change the backend URL in ONE place:
/// - `frontend/.env` (recommended)
/// - or `--dart-define=API_BASE_URL=...`
///
/// Priority order:
/// 1) `--dart-define=API_BASE_URL=...`
/// 2) `.env` value `API_BASE_URL=...` (if present)
/// 3) Platform defaults (web localhost, android emulator 10.0.2.2)
class AppConfig {
  static String get apiBaseUrl {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.trim().isNotEmpty) return fromDefine;

    var url = dotenv.env['API_BASE_URL'] ?? '';
    
    if (url.trim().isEmpty) {
      // Web: default to deployed backend
      // Emulator/Device: use emulator IP or localhost
      url = kIsWeb 
        ? 'https://team11-excelerate-flutter-project.vercel.app'  // Web deployed backend
        : 'http://10.0.2.2:3000'; // Android emulator
    }

    // Fix for Web: Chrome doesn't understand 10.0.2.2 (android emulator loopback).
    // If the URL is set to the emulator default but we are on Web, swap to localhost.
    if (kIsWeb && url.contains('10.0.2.2')) {
      url = url.replaceAll('10.0.2.2', 'localhost');
    }

    return url;
  }
}
