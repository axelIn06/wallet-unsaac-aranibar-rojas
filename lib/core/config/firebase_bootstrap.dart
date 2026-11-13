import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';
import 'firebase_status.dart';

class FirebaseBootstrap {
  static Future<FirebaseStatus> initialize() async {
    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      final requiredValues = [
        options.apiKey,
        options.appId,
        options.messagingSenderId,
        options.projectId,
      ];
      if (requiredValues.any(
        (value) => value.isEmpty || value == 'REEMPLAZAR',
      )) {
        return FirebaseStatus.notConfigured;
      }
      await Firebase.initializeApp(options: options);
      return FirebaseStatus.connected;
    } catch (_) {
      return FirebaseStatus.error;
    }
  }
}
