import 'package:equatable/equatable.dart';
import '../../domain/entities/movement.dart';

sealed class MovementsEvent extends Equatable {
  const MovementsEvent();
  @override
  List<Object> get props => [];
}

final class MovementsStarted extends MovementsEvent {
  const MovementsStarted();
}

final class MovementAdded extends MovementsEvent {
  const MovementAdded(this.movement);
  final Movement movement;
  @override
  List<Object> get props => [movement];
}

final class MovementRemoved extends MovementsEvent {
  const MovementRemoved(this.id);
  final String id;
  @override
  List<Object> get props => [id];
}

final class MovementsCleared extends MovementsEvent {
  const MovementsCleared();
}

final class MovementUpdated extends MovementsEvent {
  const MovementUpdated(this.movement);
  final Movement movement;
  @override
  List<Object> get props => [movement];
}

