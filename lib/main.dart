import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/config/firebase_status.dart';
import 'features/auth/data/firebase_auth_repository.dart';
import 'features/auth/data/in_memory_auth_repository.dart';
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
  const emulator=bool.fromEnvironment('AUTH_EMULATOR');
  final isFirebase=emulator || firebaseStatus==FirebaseStatus.connected;
  if(firebaseStatus==FirebaseStatus.error && !emulator){
    runApp(const MaterialApp(home:Scaffold(body:Center(child:Text('No se pudo inicializar Firebase. Revisa la configuración y reinicia.')))));
    return;
  }
  final auth=isFirebase ? FirebaseAuth.instanceFor(app: emulator ? await Firebase.initializeApp(demoProjectId:'demo-wallet-unsaac') : Firebase.app()) : null;
  if(emulator){await auth!.useAuthEmulator('localhost',9099);}
  runApp(
    WalletApp(
      firebaseStatus: isFirebase ? FirebaseStatus.connected : firebaseStatus,
      authRepository:auth==null ? InMemoryAuthRepository() : FirebaseAuthRepository(auth),
      preferences: preferences,
      initialMode: preferences.loadMode(),
      createWalletRepository: () => InMemoryWalletRepository(
        failFirstLoad: evidenceMode,
        failFirstAdd: const bool.fromEnvironment('DEMO_FALLO_ALTA'),
        latency: evidenceMode
            ? const Duration(seconds: 10)
            : const Duration(milliseconds: 650),
      ),
    ),
  );
}
