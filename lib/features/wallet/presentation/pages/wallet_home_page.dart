import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/firebase_status.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/theme/theme_state.dart';
import '../cubits/balance_cubit.dart';
import '../cubits/balance_state.dart';
import '../cubits/privacy_cubit.dart';
import '../cubits/privacy_state.dart';
import '../widgets/balance_card.dart';
import '../widgets/firebase_status_card.dart';
import '../widgets/movement_tile.dart';
import '../widgets/seed_color_sheet.dart';

class WalletHomePage extends StatelessWidget {
  const WalletHomePage({super.key, required this.firebaseStatus});

  final FirebaseStatus firebaseStatus;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Wallet UNSAAC'),
      actions: [
        const _ThemeModeButton(),
        IconButton(
          tooltip: 'Elegir color del tema',
          icon: const Icon(Icons.palette_outlined),
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            showDragHandle: true,
            builder: (_) => const SeedColorSheet(),
          ),
        ),
      ],
    ),
    body: SafeArea(
      child: BlocBuilder<BalanceCubit, BalanceState>(
        builder: (context, state) {
          final load = context.read<BalanceCubit>().load;
          return switch (state) {
            BalanceInitial() || BalanceLoading() => const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(semanticsLabel: 'Cargando saldo'),
                  SizedBox(height: 16),
                  Text('Cargando saldo…'),
                ],
              ),
            ),
            BalanceFailure(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_outlined, size: 44),
                    const SizedBox(height: 12),
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: load,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
            BalanceSuccess(:final summary) =>
              BlocBuilder<PrivacyCubit, PrivacyState>(
                builder: (context, privacy) => RefreshIndicator(
                  onRefresh: load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                    children: [
                      BalanceCard(
                        summary: summary,
                        hideBalance: privacy.hideBalance,
                        onToggle: context.read<PrivacyCubit>().toggle,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 18, 8, 6),
                        child: Text(
                          'Movimientos · ${summary.movements.length}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      for (final movement in summary.movements)
                        MovementTile(
                          movement: movement,
                          hideAmount: privacy.hideBalance,
                        ),
                      const SizedBox(height: 12),
                      FirebaseStatusCard(status: firebaseStatus),
                    ],
                  ),
                ),
              ),
          };
        },
      ),
    ),
  );
}

class _ThemeModeButton extends StatelessWidget {
  const _ThemeModeButton();

  @override
  Widget build(BuildContext context) =>
      BlocSelector<ThemeCubit, ThemeState, ThemeMode>(
        selector: (state) => state.mode,
        builder: (context, mode) {
          final (icon, label) = switch (mode) {
            ThemeMode.light => (Icons.light_mode_outlined, 'Claro'),
            ThemeMode.dark => (Icons.dark_mode_outlined, 'Oscuro'),
            ThemeMode.system => (Icons.brightness_auto_outlined, 'Sistema'),
          };
          return IconButton(
            icon: Icon(icon),
            tooltip: 'Tema actual: $label. Cambiar tema',
            onPressed: () async {
              try {
                await context.read<ThemeCubit>().toggle();
              } on StateError {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No se pudo guardar el tema.'),
                    ),
                  );
                }
              }
            },
          );
        },
      );
}
