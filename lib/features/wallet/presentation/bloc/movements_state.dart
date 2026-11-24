import 'package:equatable/equatable.dart';
import '../../domain/entities/wallet_summary.dart';

sealed class MovementsState extends Equatable {
  const MovementsState();
  @override
  List<Object?> get props => [];
}
final class MovementsInitial extends MovementsState { const MovementsInitial(); }
final class MovementsLoading extends MovementsState { const MovementsLoading(); }
final class MovementsReady extends MovementsState {
  const MovementsReady(this.summary);
  final WalletSummary summary;
  @override
  List<Object?> get props => [summary];
}
final class MovementsFailure extends MovementsState {
  const MovementsFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
