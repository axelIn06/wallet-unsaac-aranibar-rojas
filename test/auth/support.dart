import 'package:wallet_unsaac/features/auth/data/in_memory_auth_repository.dart';
import 'package:wallet_unsaac/features/auth/domain/auth_failure.dart';

class FakeAuthRepository extends InMemoryAuthRepository {
  bool failReset = false, failLogout = false;
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (failReset) throw const AuthException(AuthFailureReason.network);
    return super.sendPasswordResetEmail(email);
  }

  @override
  Future<void> signOut() async {
    if (failLogout) throw const AuthException(AuthFailureReason.network);
    await super.signOut();
  }

  bool loseSessionOnRefresh = false, offline = false;
  @override
  Future<void> refreshSession() async {
    if (offline) throw const AuthException(AuthFailureReason.network);
    if (loseSessionOnRefresh) await expire();
  }

  Future<void> expire() => super.signOut();
}
