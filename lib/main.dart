import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config/firebase_bootstrap.dart';
import 'core/theme/theme_preferences.dart';
import 'features/wallet/data/repositories/in_memory_wallet_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseStatus = await FirebaseBootstrap.initialize();
  final preferences = ThemePreferences(await SharedPreferences.getInstance());
  const evidenceMode = bool.fromEnvironment('DEMO_ERROR');
  runApp(
    WalletApp(
      firebaseStatus: firebaseStatus,
      preferences: preferences,
      initialMode: preferences.loadMode(),
      repository: InMemoryWalletRepository(
        failFirstLoad: evidenceMode,
        latency: evidenceMode
            ? const Duration(seconds: 10)
            : const Duration(milliseconds: 650),
      ),
    ),
  );
}
