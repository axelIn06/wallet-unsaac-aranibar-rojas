import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/wallet_summary.dart';
import '../../domain/repositories/wallet_repository.dart';
import 'movements_event.dart';
import 'movements_state.dart';

class MovementsBloc extends Bloc<MovementsEvent, MovementsState> {
  MovementsBloc(this.repository) : super(const MovementsInitial()) {
    on<MovementsStarted>((event, emit) => _enqueue(() async {
      emit(const MovementsLoading());
      await _apply(emit, repository.fetchSummary, 'cargar los movimientos');
    }));
    on<MovementAdded>((event, emit) => _enqueue(() => _apply(emit,
        () => repository.addMovement(event.movement), 'registrar el movimiento', saving: true)));
    on<MovementUpdated>((event, emit) => _enqueue(() => _apply(emit,
        () => repository.updateMovement(event.movement), 'editar el movimiento')));
    on<MovementRemoved>((event, emit) => _enqueue(() => _apply(emit,
        () => repository.removeMovement(event.id), 'eliminar el movimiento')));
    on<MovementsCleared>((event, emit) => _enqueue(() => _apply(emit,
        repository.clearMovements, 'vaciar el historial')));
  }
  final WalletRepository repository;
  // Una sola cola conserva el orden incluso entre tipos de evento distintos.
  Future<void> _pending = Future.value();
  Future<void> _enqueue(Future<void> Function() action) =>
      _pending = _pending.then((_) => action());

  Future<void> _apply(Emitter<MovementsState> emit,
      Future<WalletSummary> Function() action, String operation, {bool saving = false}) async {
    final previous = state;
    if (saving && previous is MovementsReady) emit(previous.copyWith(isSaving:true));
    try {
      final summary = await action();
      if (!emit.isDone) emit(MovementsReady(summary));
    } catch (_) {
      if (!emit.isDone) emit(MovementsFailure('No se pudo $operation.', previous is MovementsReady ? previous.copyWith(isSaving:false) : null));
    }
  }
}
