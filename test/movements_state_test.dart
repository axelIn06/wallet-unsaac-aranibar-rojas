import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/movement.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/presentation/bloc/movements_event.dart';
import 'package:wallet_unsaac/features/wallet/presentation/bloc/movements_state.dart';

void main() {
  final m = Movement(
    '1',
    'Beca',
    'Estudios',
    DateTime(2026),
    5000,
    MovementType.income,
  );
  final ready = MovementsReady(WalletSummary([m]));
  test('El movimiento compara todos sus campos', () {
    expect(m, m.copyWith());
    for (final changed in [
      m.copyWith(description: 'Otro'),
      m.copyWith(category: 'Otra'),
      m.copyWith(date: DateTime(2025)),
      m.copyWith(cents: 1),
      m.copyWith(type: MovementType.expense),
    ]) {
      expect(changed, isNot(m));
    }
  });
  test('El resumen copia la lista y protege su contenido', () {
    final source = [m];
    final summary = WalletSummary(source);
    source.clear();
    expect(summary, ready.summary);
    expect(summary.movements.clear, throwsUnsupportedError);
  });
  test('Ready distingue guardado y filtro', () {
    expect(ready, ready.copyWith());
    expect(ready, isNot(ready.copyWith(isSaving: true)));
    expect(ready, isNot(ready.copyWith(filter: MovementFilter.expense)));
  });
  test('El fallo compara su mensaje y su contexto', () {
    expect(
      MovementsFailure('Error', ready),
      MovementsFailure('Error', ready.copyWith()),
    );
    expect(
      MovementsFailure('Error', ready),
      isNot(const MovementsFailure('Error')),
    );
  });
  test('Los eventos distinguen intención y carga útil', () {
    expect(MovementUpdated(m), MovementUpdated(m.copyWith()));
    expect(MovementAdded(m), isNot(MovementUpdated(m)));
    expect(const MovementRemoved('1'), isNot(const MovementRemoved('2')));
  });
}
