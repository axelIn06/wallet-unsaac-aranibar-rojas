import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_unsaac/app.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';
import 'package:wallet_unsaac/features/auth/data/in_memory_auth_repository.dart';
import 'package:wallet_unsaac/features/auth/presentation/auth_bloc.dart';
import 'package:wallet_unsaac/features/wallet/data/repositories/in_memory_wallet_repository.dart';
import 'support.dart';

Future<void> openWallet(WidgetTester tester, FakeAuthRepository repo) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    WalletApp(
      firebaseStatus: FirebaseStatus.notConfigured,
      preferences: ThemePreferences(await SharedPreferences.getInstance()),
      initialMode: ThemeMode.light,
      authRepository: repo,
      createWalletRepository: () =>
          InMemoryWalletRepository(latency: Duration.zero),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  Future<void> tap(WidgetTester t, Finder item) async {
    await t.ensureVisible(item);
    await t.tap(item);
    await t.pumpAndSettle();
  }

  final submit = find.widgetWithText(FilledButton, 'Iniciar sesión');
  testWidgets('Formulario vacío conserva acceso y explica ambos campos', (
    t,
  ) async {
    await openWallet(t, FakeAuthRepository());
    await tap(t, submit);
    expect(find.text('Ingresa un correo válido.'), findsOneWidget);
    expect(find.text('Usa al menos 6 caracteres.'), findsOneWidget);
  });
  testWidgets('Acceso inválido conserva los campos y muestra mensaje', (
    t,
  ) async {
    await openWallet(t, FakeAuthRepository());
    await t.enterText(find.byType(TextFormField).at(0), 'nadie@example.test');
    await t.enterText(find.byType(TextFormField).at(1), 'invalida');
    await tap(t, submit);
    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
    expect(find.text('nadie@example.test'), findsOneWidget);
  });
  testWidgets('Acceso, expiración y acción de retorno', (t) async {
    final repo = FakeAuthRepository();
    await openWallet(t, repo);
    await t.enterText(
      find.byType(TextFormField).at(0),
      InMemoryAuthRepository.demoEmail,
    );
    await t.enterText(
      find.byType(TextFormField).at(1),
      InMemoryAuthRepository.demoPassword,
    );
    await tap(t, submit);
    expect(find.text('Saldo disponible'), findsOneWidget);
    await repo.expire();
    await t.pumpAndSettle();
    expect(find.text(AuthBloc.expired), findsOneWidget);
    expect(find.text('Saldo disponible'), findsNothing);
    await tap(t, find.text('Volver a iniciar sesión'));
    expect(submit, findsOneWidget);
  });
  testWidgets('Registro exige confirmación y abre la billetera', (t) async {
    await openWallet(t, FakeAuthRepository());
    await tap(t, find.text('Registrarme'));
    await t.enterText(find.byType(TextFormField).at(0), 'nueva@example.test');
    await t.enterText(find.byType(TextFormField).at(1), 'ejemplo123');
    final register = find.widgetWithText(FilledButton, 'Crear cuenta');
    await tap(t, register);
    expect(find.text('Las contraseñas deben coincidir.'), findsOneWidget);
    await t.enterText(find.byType(TextFormField).at(2), 'ejemplo123');
    await tap(t, register);
    expect(find.text('Saldo disponible'), findsOneWidget);
  });
  testWidgets('Recuperar desde el enlace muestra confirmación genérica', (
    t,
  ) async {
    await openWallet(t, FakeAuthRepository());
    await tap(t, find.text('¿Olvidaste tu contraseña?'));
    await t.enterText(find.byType(TextFormField), 'nadie@example.test');
    await tap(t, find.text('Solicitar instrucciones'));
    expect(find.text(AuthPasswordResetRequested.confirmation), findsOneWidget);
  });
}
