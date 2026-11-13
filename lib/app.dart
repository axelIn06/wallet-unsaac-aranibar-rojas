import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/firebase_status.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/theme/theme_preferences.dart';
import 'core/theme/theme_state.dart';
import 'features/wallet/domain/repositories/wallet_repository.dart';
import 'features/wallet/presentation/cubits/balance_cubit.dart';
import 'features/wallet/presentation/cubits/privacy_cubit.dart';
import 'features/wallet/presentation/pages/wallet_home_page.dart';

class WalletApp extends StatelessWidget {
  const WalletApp({
    super.key,
    required this.firebaseStatus,
    required this.preferences,
    required this.initialMode,
    required this.repository,
  });

  final FirebaseStatus firebaseStatus;
  final ThemePreferences preferences;
  final ThemeMode initialMode;
  final WalletRepository repository;

  @override
  Widget build(BuildContext context) =>
      RepositoryProvider<WalletRepository>.value(
        value: repository,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ThemeCubit(preferences, initialMode)),
            BlocProvider(create: (_) => PrivacyCubit()),
            BlocProvider(
              create: (context) =>
                  BalanceCubit(context.read<WalletRepository>())..load(),
            ),
          ],
          child: BlocBuilder<ThemeCubit, ThemeState>(
            builder: (_, state) => MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Wallet UNSAAC',
              theme: AppTheme.light(state.seedColor),
              darkTheme: AppTheme.dark(state.seedColor),
              themeMode: state.mode,
              home: WalletHomePage(firebaseStatus: firebaseStatus),
            ),
          ),
        ),
      );
}
