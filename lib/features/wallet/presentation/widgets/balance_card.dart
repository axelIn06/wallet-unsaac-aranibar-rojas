import 'package:flutter/material.dart';

import '../../../../core/utils/money.dart';
import '../../domain/entities/wallet_summary.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.summary,
    required this.hideBalance,
    required this.onToggle,
  });

  final WalletSummary summary;
  final bool hideBalance;
  final VoidCallback onToggle;

  String _amount(int cents) => hideBalance ? '••••' : MoneyFormat.cents(cents);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: colors.onPrimaryContainer),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(child: Text('Saldo disponible')),
                  IconButton(
                    color: colors.onPrimaryContainer,
                    onPressed: onToggle,
                    tooltip: hideBalance ? 'Mostrar saldo' : 'Ocultar saldo',
                    icon: Icon(
                      hideBalance ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ],
              ),
              Text(
                _amount(summary.balanceCents),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: colors.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 30,
                runSpacing: 8,
                children: [
                  _Total(
                    label: 'Ingresos',
                    amount: _amount(summary.incomeCents),
                  ),
                  _Total(
                    label: 'Egresos',
                    amount: _amount(summary.expenseCents),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label),
      Text(amount, style: const TextStyle(fontWeight: FontWeight.w600)),
    ],
  );
}
