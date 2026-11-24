import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/firebase_status.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/theme/theme_state.dart';
import '../bloc/movements_bloc.dart';
import '../bloc/movements_event.dart';
import '../../domain/entities/movement.dart';
import 'movement_editor.dart';
import '../bloc/movements_state.dart';
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
            builder: (_) => BlocProvider.value(value: context.read<ThemeCubit>(), child: const SeedColorSheet()),
          ),
        ),
      ],
    ),
    body: SafeArea(child: BlocBuilder<MovementsBloc, MovementsState>(
      builder: (context, state) => switch(state) {
        MovementsInitial() || MovementsLoading() => const Center(child: CircularProgressIndicator()),
        MovementsFailure(:final message) => Center(child: Column(mainAxisSize: MainAxisSize.min,
          children: [Text(message), TextButton(onPressed: () => context.read<MovementsBloc>().add(const MovementsStarted()),
          child: const Text('Reintentar'))])),
        MovementsReady() => _WalletContent(state: state, firebaseStatus: firebaseStatus),
      },
    )),
  );
}

class _WalletContent extends StatelessWidget {
  const _WalletContent({required this.state, required this.firebaseStatus});
  final MovementsReady state;
  final FirebaseStatus firebaseStatus;
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MovementsBloc>();
    final hide = context.select((PrivacyCubit cubit) => cubit.state.hideBalance);
    final summary = state.summary;
    return ListView(padding: const EdgeInsets.fromLTRB(12,4,12,20), children: [
      BalanceCard(summary: summary, hideBalance: hide, onToggle: context.read<PrivacyCubit>().toggle),
      if (state.isSaving) const LinearProgressIndicator(semanticsLabel:'Guardando'),
      Wrap(alignment: WrapAlignment.spaceBetween, children: [
        for (final type in MovementType.values)
          TextButton.icon(icon: Icon(type == MovementType.income ? Icons.add : Icons.remove),
            label: Text(type == MovementType.income ? 'Ingreso' : 'Egreso'),
            onPressed: () {final now = DateTime.now();
              bloc.add(MovementAdded(Movement('local-${now.microsecondsSinceEpoch}',
                type == MovementType.income ? 'Ingreso de práctica' : 'Egreso de práctica',
                'Práctica', now, 1000, type)));}),
        IconButton(tooltip: 'Vaciar historial', icon: const Icon(Icons.delete_sweep_outlined),
          onPressed: () async {
            final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
              title: const Text('¿Vaciar historial?'), content: const Text('Se eliminarán todos los movimientos de esta sesión.'),
              actions: [TextButton(onPressed: () => Navigator.pop(ctx,false), child: const Text('Cancelar')),
              FilledButton(onPressed: () => Navigator.pop(ctx,true),child: const Text('Vaciar'))]));
            if (confirmed == true && !bloc.isClosed) bloc.add(const MovementsCleared());
          }),
      ]),
      Text('Movimientos · ${summary.movements.length}'),
      for (final movement in summary.movements)
        MovementTile(movement: movement, hideAmount: hide,
          onDelete: () => bloc.add(MovementRemoved(movement.id)),
          onEdit: () async {
            final edited = await showDialog<Movement>(context: context, builder: (_) => MovementEditor(movement));
            if (edited != null && !bloc.isClosed) bloc.add(MovementUpdated(edited));
          }),
      FirebaseStatusCard(status: firebaseStatus),
    ]);
  }
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
