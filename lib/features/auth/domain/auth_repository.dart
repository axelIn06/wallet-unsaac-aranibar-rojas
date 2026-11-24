import 'auth_user.dart';

abstract interface class AuthRepository {
  AuthUser? get currentUser;
  Stream<AuthUser?> authStateChanges();
  Future<AuthUser> signIn(String email, String password);
  Future<AuthUser> register(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<AuthUser> updateDisplayName(String name);
  Future<void> signOut();
}
