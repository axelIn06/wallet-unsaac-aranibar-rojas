import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/money.dart';
import '../../domain/entities/movement.dart';

class MovementTile extends StatelessWidget {
  const MovementTile({
    super.key,
    required this.movement,
    required this.hideAmount,
  });

  final Movement movement;
  final bool hideAmount;

  @override
  Widget build(BuildContext context) {
    final income = movement.type == MovementType.income;
    final colors = Theme.of(context).colorScheme;
    final sign = income ? '+' : '−';
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: CircleAvatar(
        backgroundColor: colors.secondaryContainer,
        foregroundColor: colors.onSecondaryContainer,
        child: Icon(income ? Icons.south_west : Icons.north_east),
      ),
      title: Text(movement.description),
      subtitle: Text(
        '${movement.category} · ${DateFormat('dd/MM/yyyy').format(movement.date)}',
      ),
      trailing: Text(
        hideAmount ? '••••' : '$sign${MoneyFormat.cents(movement.cents)}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
