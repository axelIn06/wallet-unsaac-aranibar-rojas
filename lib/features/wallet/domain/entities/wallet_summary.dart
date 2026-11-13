import 'movement.dart';

class WalletSummary {
  WalletSummary(Iterable<Movement> movements)
    : movements = List.unmodifiable(movements);

  final List<Movement> movements;

  int get incomeCents => _total(MovementType.income);
  int get expenseCents => _total(MovementType.expense);
  int get balanceCents => incomeCents - expenseCents;

  int _total(MovementType type) => movements
      .where((movement) => movement.type == type)
      .fold(0, (sum, movement) => sum + movement.cents);
}
