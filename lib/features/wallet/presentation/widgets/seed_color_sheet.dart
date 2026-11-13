import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/theme/theme_state.dart';

class SeedColorSheet extends StatelessWidget {
  const SeedColorSheet({super.key});

  static const _colors = {
    'Granate': AppTheme.seed,
    'Azul': Color(0xFF1565C0),
    'Verde': Color(0xFF2E7D32),
    'Violeta': Color(0xFF6A1B9A),
  };

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Color del tema', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in _colors.entries)
                BlocSelector<ThemeCubit, ThemeState, bool>(
                  selector: (state) => state.seedColor == entry.value,
                  builder: (context, selected) => ChoiceChip(
                    label: Text(entry.key),
                    avatar: CircleAvatar(backgroundColor: entry.value),
                    selected: selected,
                    onSelected: (_) =>
                        context.read<ThemeCubit>().setSeedColor(entry.value),
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
