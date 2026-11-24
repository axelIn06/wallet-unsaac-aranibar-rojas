import 'package:equatable/equatable.dart';
import '../../domain/entities/wallet_summary.dart';
import '../../domain/entities/movement.dart';

enum MovementFilter { all, income, expense }

sealed class MovementsState extends Equatable {
  const MovementsState();
  MovementsReady? get content => switch(this) { MovementsReady ready => ready, MovementsFailure(:final previous) => previous, _ => null };
  @override
  List<Object?> get props => [];
}
final class MovementsInitial extends MovementsState { const MovementsInitial(); }
final class MovementsLoading extends MovementsState { const MovementsLoading(); }
final class MovementsReady extends MovementsState {
  const MovementsReady(this.summary, {this.isSaving = false, this.filter = MovementFilter.all});
  final MovementFilter filter;
  List<Movement> get visibleMovements => switch(filter) {
    MovementFilter.all => summary.movements,
    MovementFilter.income => summary.movements.where((m) => m.type == MovementType.income).toList(growable:false),
    MovementFilter.expense => summary.movements.where((m) => m.type == MovementType.expense).toList(growable:false),
  };
  final bool isSaving;
  MovementsReady copyWith({WalletSummary? summary, bool? isSaving, MovementFilter? filter}) => MovementsReady(summary ?? this.summary, filter: filter ?? this.filter, isSaving: isSaving ?? this.isSaving);
  final WalletSummary summary;
  @override
  List<Object?> get props => [summary, isSaving, filter];
}
final class MovementsFailure extends MovementsState {
  const MovementsFailure(this.message, [this.previous]);
  final MovementsReady? previous;
  final String message;
  @override
  List<Object?> get props => [message, previous];
}
