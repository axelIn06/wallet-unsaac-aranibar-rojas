import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/features/wallet/data/repositories/in_memory_wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/movement.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/presentation/bloc/movements_bloc.dart';
import 'package:wallet_unsaac/features/wallet/presentation/bloc/movements_event.dart';
import 'package:wallet_unsaac/features/wallet/presentation/bloc/movements_state.dart';

void main() {
  final day = DateTime(2026, 11, 11);
  final credit = Movement(
    'a',
    'Beca',
    'Estudios',
    day,
    10000,
    MovementType.income,
  );
  final debit = Movement(
    'b',
    'Pasaje',
    'Transporte',
    day,
    500,
    MovementType.expense,
  );
  final extra = Movement(
    'c',
    'Libro',
    'Estudios',
    day,
    2600,
    MovementType.expense,
  );
  final seed = [credit, debit];
  final ready = MovementsReady(WalletSummary(seed));
  MovementsBloc build({bool fail = false}) => MovementsBloc(
    InMemoryWalletRepository(
      seed: seed,
      latency: Duration.zero,
      failFirstLoad: fail,
    ),
  );
  Future<void> dispatch(
    MovementsBloc bloc,
    MovementsEvent event,
    bool Function(MovementsState) done,
  ) {
    final completed = bloc.stream.firstWhere(done);
    bloc.add(event);
    return completed.then((_) {});
  }

  test('Estado inicial antes de solicitar la carga', () async {
    final bloc = build();
    expect(bloc.state, const MovementsInitial());
    await bloc.close();
  });
  blocTest<MovementsBloc, MovementsState>(
    'Carga el resumen de dos movimientos',
    build: build,
    act: (b) =>
        dispatch(b, const MovementsStarted(), (s) => s is MovementsReady),
    expect: () => [const MovementsLoading(), ready],
  );
  blocTest<MovementsBloc, MovementsState>(
    'Alta conserva lista durante el guardado y actualiza el saldo',
    build: build,
    seed: () => ready,
    act: (b) => dispatch(
      b,
      MovementAdded(extra),
      (s) => s is MovementsReady && !s.isSaving,
    ),
    expect: () => [
      ready.copyWith(isSaving: true),
      MovementsReady(WalletSummary([extra, ...seed])),
    ],
  );
  blocTest<MovementsBloc, MovementsState>(
    'Baja por identificador',
    build: build,
    seed: () => ready,
    act: (b) =>
        dispatch(b, const MovementRemoved('a'), (s) => s is MovementsReady),
    expect: () => [
      MovementsReady(WalletSummary([debit])),
    ],
  );
  blocTest<MovementsBloc, MovementsState>(
    'Vaciar historial',
    build: build,
    seed: () => ready,
    act: (b) =>
        dispatch(b, const MovementsCleared(), (s) => s is MovementsReady),
    expect: () => [MovementsReady(WalletSummary([]))],
  );
  blocTest<MovementsBloc, MovementsState>(
    'Fallo inicial y recuperación',
    build: () => build(fail: true),
    act: (b) async {
      await dispatch(b, const MovementsStarted(), (s) => s is MovementsFailure);
      await dispatch(b, const MovementsStarted(), (s) => s is MovementsReady);
    },
    expect: () => [
      const MovementsLoading(),
      const MovementsFailure('No se pudo cargar los movimientos.'),
      const MovementsLoading(),
      ready,
    ],
  );
  blocTest<MovementsBloc, MovementsState>(
    'Baja inexistente suprime estado equivalente después de la carga',
    build: build,
    act: (b) async {
      await dispatch(b, const MovementsStarted(), (s) => s is MovementsReady);
      b.add(const MovementRemoved('ausente'));
      await dispatch(
        b,
        const MovementsCleared(),
        (s) => s is MovementsReady && s.summary.movements.isEmpty,
      );
    },
    expect: () => [
      const MovementsLoading(),
      ready,
      MovementsReady(WalletSummary([])),
    ],
  );
  final edited = debit.copyWith(cents: 850, description: 'Pasaje corregido');
  blocTest<MovementsBloc, MovementsState>(
    'Editar conserva posición, id, cantidad y recalcula saldo',
    build: build,
    seed: () => ready,
    act: (b) =>
        dispatch(b, MovementUpdated(edited), (s) => s is MovementsReady),
    expect: () => [
      MovementsReady(WalletSummary([credit, edited])),
    ],
    verify: (b) {
      final summary = (b.state as MovementsReady).summary;
      expect(summary.balanceCents, 9150);
      expect(summary.movements.last.id, 'b');
      expect(ready.summary.balanceCents, 9500);
    },
  );
  blocTest<MovementsBloc, MovementsState>(
    'Alta duplicada mantiene los datos anteriores',
    build: build,
    seed: () => ready,
    act: (b) =>
        dispatch(b, MovementAdded(credit), (s) => s is MovementsFailure),
    expect: () => [
      ready.copyWith(isSaving: true),
      MovementsFailure('No se pudo registrar el movimiento.', ready),
    ],
  );
  for (final filter in MovementFilter.values) {
    final from = filter == MovementFilter.all
        ? MovementFilter.income
        : MovementFilter.all;
    blocTest<MovementsBloc, MovementsState>(
      'Filtro ${filter.name} mantiene resumen y saldo',
      build: build,
      seed: () => ready.copyWith(filter: from),
      act: (b) => dispatch(
        b,
        MovementsFilterChanged(filter),
        (s) => s is MovementsReady,
      ),
      expect: () => [ready.copyWith(filter: filter)],
      verify: (b) {
        final result = b.state as MovementsReady;
        expect(result.summary, same(ready.summary));
        expect(result.summary.balanceCents, 9500);
        expect(result.visibleMovements, switch (filter) {
          MovementFilter.all => seed,
          MovementFilter.income => [credit],
          MovementFilter.expense => [debit],
        });
      },
    );
  }
  blocTest<MovementsBloc, MovementsState>(
    'Conserva el filtro al agregar',
    build: build,
    seed: () => ready.copyWith(filter: MovementFilter.income),
    act: (b) => dispatch(
      b,
      MovementAdded(extra),
      (s) => s is MovementsReady && !s.isSaving,
    ),
    verify: (b) {
      final s = b.state as MovementsReady;
      expect(s.visibleMovements, [credit]);
      expect(s.summary.balanceCents, 6900);
    },
  );
  test('Alta y baja consecutivas conservan ambas escrituras', () async {
    final bloc = build();
    await dispatch(bloc, const MovementsStarted(), (s) => s is MovementsReady);
    bloc.add(MovementAdded(extra));
    await dispatch(
      bloc,
      const MovementRemoved('b'),
      (s) =>
          s is MovementsReady &&
          s.summary.movements.length == 2 &&
          s.summary.movements.first == extra,
    );
    expect((bloc.state as MovementsReady).summary.balanceCents, 7400);
    await bloc.close();
  });
}
