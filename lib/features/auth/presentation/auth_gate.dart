import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_bloc.dart';
import 'auth_form.dart';
import '../domain/auth_user.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.wallet, required this.local});
  final Widget Function(AuthUser) wallet;
  final bool local;
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<AuthBloc>().add(const AuthResumed());
    }
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<AuthBloc, AuthState>(
    listener: (context, state) {
      final message = switch (state) {
        AuthAuthenticated(:final message) ||
        AuthUnauthenticated(:final message) => message,
        _ => null,
      };
      if (message != null) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        if (state is AuthUnauthenticated) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
        messenger.showSnackBar(
          SnackBar(
            content: Text(message),
            action: message == AuthBloc.expired
                ? SnackBarAction(
                    label: 'Volver a iniciar sesión',
                    onPressed: () => context.read<AuthBloc>().add(
                      const AuthLoginPromptRequested(),
                    ),
                  )
                : null,
          ),
        );
      }
    },
    buildWhen: (previous, current) => current is! AuthLoading,
    builder: (_, state) => switch (state) {
      AuthAuthenticated(:final user) => widget.wallet(user),
      AuthUnauthenticated() => AuthForm(
        key: ValueKey(state.message == AuthBloc.expired),
        local: widget.local,
      ),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    },
  );
}
