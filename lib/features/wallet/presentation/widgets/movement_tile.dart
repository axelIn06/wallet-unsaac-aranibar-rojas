import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/money.dart';
import '../../domain/entities/movement.dart';

class MovementTile extends StatelessWidget {
  const MovementTile({
    super.key,
    required this.onEdit, required this.onDelete,
    required this.movement,
    required this.hideAmount,
  });

  final VoidCallback onEdit, onDelete;
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
      trailing: Row(mainAxisSize: MainAxisSize.min, children:[Text(
        hideAmount ? '••••' : '$sign${MoneyFormat.cents(movement.cents)}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ), PopupMenuButton<String>(tooltip: 'Acciones de ${movement.description}',
        onSelected: (action) => action == 'edit' ? onEdit() : onDelete(),
        itemBuilder: (_) => const [PopupMenuItem(value: 'edit',child:Text('Editar')), PopupMenuItem(value: 'delete',child:Text('Eliminar'))])]),
    );
  }
}
