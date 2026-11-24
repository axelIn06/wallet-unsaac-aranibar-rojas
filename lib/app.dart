import 'features/auth/domain/auth_repository.dart';
import 'features/auth/presentation/auth_bloc.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/firebase_status.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/theme/theme_preferences.dart';
import 'core/theme/theme_state.dart';
import 'features/wallet/domain/repositories/wallet_repository.dart';
import 'features/wallet/presentation/bloc/movements_bloc.dart';
import 'features/wallet/presentation/bloc/movements_event.dart';
import 'features/wallet/presentation/cubits/privacy_cubit.dart';
import 'features/wallet/presentation/pages/wallet_home_page.dart';

class WalletApp extends StatelessWidget {
  const WalletApp({
    super.key,
    required this.firebaseStatus,
    required this.preferences,
    required this.initialMode,
    required this.createWalletRepository,
    required this.authRepository,
  });

  final FirebaseStatus firebaseStatus;
  final ThemePreferences preferences;
  final ThemeMode initialMode;
  final WalletRepository Function() createWalletRepository;
  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) =>
      RepositoryProvider<AuthRepository>.value(
        value: authRepository,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ThemeCubit(preferences, initialMode)),
            BlocProvider(
              lazy: false,
              create: (context) =>
                  AuthBloc(context.read<AuthRepository>())
                    ..add(const AuthStarted()),
            ),
          ],
          child: BlocBuilder<ThemeCubit, ThemeState>(
            builder: (_, state) => MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Wallet UNSAAC',
              theme: AppTheme.light(state.seedColor),
              darkTheme: AppTheme.dark(state.seedColor),
              themeMode: state.mode,
              home: AuthGate(
                local: firebaseStatus == FirebaseStatus.notConfigured,
                wallet: (user) => RepositoryProvider<WalletRepository>(
                  key: ValueKey(user.uid),
                  create: (_) => createWalletRepository(),
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider(create: (_) => PrivacyCubit()),
                      BlocProvider(
                        create: (ctx) =>
                            MovementsBloc(ctx.read<WalletRepository>())
                              ..add(const MovementsStarted()),
                      ),
                    ],
                    child: WalletHomePage(
                      firebaseStatus: firebaseStatus,
                      user: user,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
