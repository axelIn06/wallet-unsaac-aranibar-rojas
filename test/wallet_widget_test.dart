import 'package:wallet_unsaac/features/auth/data/in_memory_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_unsaac/app.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';
import 'package:wallet_unsaac/features/wallet/data/repositories/in_memory_wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/presentation/widgets/balance_card.dart';

class _CountingRepository extends InMemoryWalletRepository {
  _CountingRepository({super.failFirstLoad, super.failFirstAdd})
    : super(latency: Duration.zero);

  int calls = 0;

  @override
  Future<WalletSummary> fetchSummary() {
    calls++;
    return super.fetchSummary();
  }
}

Future<void> _open(WidgetTester tester, _CountingRepository repository) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = ThemePreferences(await SharedPreferences.getInstance());
  final auth=InMemoryAuthRepository();
  await auth.signIn(InMemoryAuthRepository.demoEmail,InMemoryAuthRepository.demoPassword);
  await tester.pumpWidget(
    WalletApp(
      firebaseStatus: FirebaseStatus.notConfigured,
      preferences: preferences,
      initialMode: ThemeMode.light,
      createWalletRepository: () => repository,
      authRepository:auth,
    ),
  );
}

void main() {
  testWidgets('La carga termina con saldo, totales y movimientos', (
    tester,
  ) async {
    await _open(tester, _CountingRepository());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('S/ 1,274.60'), findsOneWidget);
    expect(find.text('S/ 1,770.00'), findsOneWidget);
    expect(find.text('S/ 495.40'), findsOneWidget);
    expect(find.text('Movimientos · 7'), findsOneWidget);
    expect(find.text('Plan de internet'), findsOneWidget);
  });

  testWidgets('El ojo enmascara los importes y los restaura sin recargar', (
    tester,
  ) async {
    final repository = _CountingRepository();
    await _open(tester, repository);
    await tester.pumpAndSettle();
    final amounts = find.textContaining('S/ ');
    final visible = tester
        .widgetList<Text>(amounts)
        .map((text) => text.data)
        .toList();
    expect(visible.length, greaterThanOrEqualTo(4));
    await tester.tap(find.byTooltip('Ocultar saldo'));
    await tester.pumpAndSettle();
    expect(amounts, findsNothing);
    expect(find.text('••••'), findsAtLeastNWidgets(4));
    expect(find.text('Plan de internet'), findsOneWidget);
    await tester.tap(find.byTooltip('Mostrar saldo'));
    await tester.pumpAndSettle();
    expect(tester.widgetList<Text>(amounts).map((text) => text.data), visible);
    expect(repository.calls, 1);
  });

  testWidgets('El selector aplica el color y marca la opción en ambos modos', (
    tester,
  ) async {
    await _open(tester, _CountingRepository());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Elegir color del tema'));
    await tester.pumpAndSettle();
    expect(find.byType(ChoiceChip), findsNWidgets(4));
    await tester.tap(find.text('Azul'));
    await tester.pumpAndSettle();
    final azul = find.widgetWithText(ChoiceChip, 'Azul');
    expect(tester.widget<ChoiceChip>(azul).selected, isTrue);
    final card = find.byType(BalanceCard);
    ColorScheme scheme() => Theme.of(tester.element(card)).colorScheme;
    const seed = Color(0xFF1565C0);
    expect(scheme().primary, ColorScheme.fromSeed(seedColor: seed).primary);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tema actual: Claro. Cambiar tema'));
    await tester.pumpAndSettle();
    expect(
      scheme().primary,
      ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ).primary,
    );
  });

  testWidgets('Reintentar desde el error recupera los movimientos', (
    tester,
  ) async {
    final repository = _CountingRepository(failFirstLoad: true);
    await _open(tester, repository);
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    await tester.tap(find.widgetWithText(SnackBarAction, 'Reintentar'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('S/ 1,274.60'), findsOneWidget);
    expect(repository.calls, 2);
  });

  testWidgets('Un fallo de alta conserva lista y saldo hasta reintentar', (
    tester,
  ) async {
    final repository = _CountingRepository(failFirstAdd: true);
    await _open(tester, repository);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ingreso'));
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(SnackBar, 'No se pudo registrar el movimiento.'),
      findsOneWidget,
    );
    expect(find.text('Plan de internet'), findsOneWidget);
    expect(find.text('S/ 1,274.60'), findsOneWidget);
    await tester.tap(find.widgetWithText(SnackBarAction, 'Reintentar'));
    await tester.pumpAndSettle();
    expect(repository.calls, 2);
    expect(find.text('Movimientos · 7'), findsOneWidget);
  });
  testWidgets('Editar desde el menú actualiza el título y el saldo', (
    tester,
  ) async {
    await _open(tester, _CountingRepository());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Acciones de Plan de internet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Internet corregido',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '80,00');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Internet corregido'), findsOneWidget);
    expect(find.text('S/ 1,284.50'), findsOneWidget);
    expect(find.text('Movimientos · 7'), findsOneWidget);
  });
}
