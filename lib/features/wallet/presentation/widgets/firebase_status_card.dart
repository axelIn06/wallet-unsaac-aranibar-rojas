import 'package:flutter/material.dart';

import '../../../../core/config/firebase_status.dart';

class FirebaseStatusCard extends StatelessWidget {
  const FirebaseStatusCard({super.key, required this.status});

  final FirebaseStatus status;

  @override
  Widget build(BuildContext context) {
    final (icon, title, description) = switch (status) {
      FirebaseStatus.connected => (
        Icons.cloud_done_outlined,
        'Firebase: conectado',
        'SDK inicializado. Los movimientos siguen siendo de demostración.',
      ),
      FirebaseStatus.notConfigured => (
        Icons.cloud_off_outlined,
        'Firebase: no configurado',
        'La billetera funciona con datos locales de demostración.',
      ),
      FirebaseStatus.error => (
        Icons.error_outline,
        'Firebase: error',
        'No se pudo inicializar Firebase. La billetera local sigue disponible.',
      ),
    };
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }
}
