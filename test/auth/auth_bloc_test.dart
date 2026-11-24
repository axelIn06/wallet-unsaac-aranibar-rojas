import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/features/auth/presentation/auth_bloc.dart';
import 'package:wallet_unsaac/features/auth/domain/auth_failure.dart';
import 'package:wallet_unsaac/features/auth/data/in_memory_auth_repository.dart';
import 'support.dart';

void main() {
  const email = InMemoryAuthRepository.demoEmail,
      password = InMemoryAuthRepository.demoPassword;
  late FakeAuthRepository repo;
  late AuthBloc bloc;
  Future<AuthState> send(AuthEvent event, bool Function(AuthState) predicate) {
    final next = bloc.stream.firstWhere(predicate);
    bloc.add(event);
    return next;
  }

  Future<void> start() async {
    await send(const AuthStarted(), (s) => s is AuthUnauthenticated);
  }

  Future<AuthAuthenticated> login() async =>
      await send(
            const AuthLoginRequested(email, password),
            (s) => s is AuthAuthenticated,
          )
          as AuthAuthenticated;
  setUp(() {
    repo = FakeAuthRepository();
    bloc = AuthBloc(repo);
  });
  tearDown(() => bloc.close());
  test('El estado inicial espera al observador', () {
    expect(bloc.state, const AuthInitial());
  });
  test('Un stream sin usuario conduce al acceso', () async {
    await start();
    expect(bloc.state, const AuthUnauthenticated());
  });
  test('Restaura la identidad inicial del stream', () async {
    final user = await repo.signIn(email, password);
    expect(
      await send(const AuthStarted(), (s) => s is AuthAuthenticated),
      AuthAuthenticated(user),
    );
  });
  test('Acceso correcto emite carga y billetera', () async {
    await start();
    final states = <AuthState>[];
    final sub = bloc.stream.listen(states.add);
    await login();
    expect(states, [const AuthLoading(), AuthAuthenticated(repo.currentUser!)]);
    await sub.cancel();
  });
  test('Credenciales inválidas producen un mensaje genérico', () async {
    await start();
    expect(
      await send(
        const AuthLoginRequested(email, 'incorrecta'),
        (s) => s is AuthUnauthenticated,
      ),
      AuthUnauthenticated(AuthFailureReason.invalidCredentials.message),
    );
  });
  test('Registro nuevo autentica y normaliza el correo', () async {
    await start();
    await send(
      const AuthRegisterRequested('  ALUMNA@example.test ', password),
      (s) => s is AuthAuthenticated,
    );
    expect(repo.currentUser!.email, 'alumna@example.test');
  });
  test('Registro duplicado informa el conflicto', () async {
    await start();
    expect(
      await send(
        const AuthRegisterRequested(email, password),
        (s) => s is AuthUnauthenticated,
      ),
      AuthUnauthenticated(AuthFailureReason.emailInUse.message),
    );
  });
  for (final candidate in [email, 'ausente@example.test']) {
    test('Recuperación genérica para $candidate', () async {
      await start();
      expect(
        await send(
          AuthPasswordResetRequested(candidate),
          (s) => s is AuthUnauthenticated,
        ),
        const AuthUnauthenticated(AuthPasswordResetRequested.confirmation),
      );
    });
  }
  test('Recuperación con fallo de red informa el error', () async {
    await start();
    repo.failReset = true;
    expect(
      await send(
        const AuthPasswordResetRequested(email),
        (s) => s is AuthUnauthenticated,
      ),
      AuthUnauthenticated(AuthFailureReason.network.message),
    );
  });
}
