import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/wallet_repository.dart';
import 'balance_state.dart';

class BalanceCubit extends Cubit<BalanceState> {
  BalanceCubit(this._repository) : super(const BalanceInitial());

  static const failureMessage = 'No se pudo cargar el saldo. Intenta de nuevo.';
  final WalletRepository _repository;

  Future<void> load() async {
    if (isClosed || state is BalanceLoading) return;
    emit(const BalanceLoading());
    try {
      final summary = await _repository.fetchSummary();
      if (!isClosed) emit(BalanceSuccess(summary));
    } on Exception {
      if (!isClosed) emit(const BalanceFailure(failureMessage));
    }
  }
}
