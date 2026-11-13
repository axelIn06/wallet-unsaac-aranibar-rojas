import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/balance_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/balance_state.dart';

class _ScriptedRepository implements WalletRepository {
  _ScriptedRepository(this.responses);

  final List<Future<WalletSummary> Function()> responses;
  int calls = 0;

  @override
  Future<WalletSummary> fetchSummary() => responses[calls++]();
}

void main() {
  final summary = WalletSummary([]);
  const failure = BalanceFailure(BalanceCubit.failureMessage);
  late _ScriptedRepository repository;

  blocTest<BalanceCubit, BalanceState>(
    'Éxito emite carga y resultado',
    build: () {
      repository = _ScriptedRepository([() async => summary]);
      return BalanceCubit(repository);
    },
    act: (cubit) => cubit.load(),
    expect: () => [const BalanceLoading(), BalanceSuccess(summary)],
  );

  blocTest<BalanceCubit, BalanceState>(
    'Una excepción emite carga y fallo',
    build: () {
      repository = _ScriptedRepository([
        () async => throw Exception('Sin datos'),
      ]);
      return BalanceCubit(repository);
    },
    act: (cubit) => cubit.load(),
    expect: () => [const BalanceLoading(), failure],
  );

  blocTest<BalanceCubit, BalanceState>(
    'Reintentar vuelve al repositorio y recupera el saldo',
    build: () {
      repository = _ScriptedRepository([
        () async => throw Exception('Temporal'),
        () async => summary,
      ]);
      return BalanceCubit(repository);
    },
    act: (cubit) async {
      await cubit.load();
      await cubit.load();
    },
    expect: () => [
      const BalanceLoading(),
      failure,
      const BalanceLoading(),
      BalanceSuccess(summary),
    ],
    verify: (_) => expect(repository.calls, 2),
  );

  test(
    'Se ignora una segunda carga y un resultado posterior al cierre',
    () async {
      final response = Completer<WalletSummary>();
      repository = _ScriptedRepository([() => response.future]);
      final cubit = BalanceCubit(repository);
      final first = cubit.load();
      await cubit.load();
      await cubit.close();
      response.complete(summary);
      await first;
      expect(repository.calls, 1);
      expect(cubit.state, const BalanceLoading());
    },
  );
}
