import 'package:firebase_auth/firebase_auth.dart' as sdk;
import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

AuthFailureReason mapAuthCode(String code) => switch(code) {
  'invalid-credential' || 'invalid-login-credentials' || 'wrong-password' || 'user-not-found' => AuthFailureReason.invalidCredentials,
  'invalid-email' => AuthFailureReason.invalidEmail,
  'email-already-in-use' => AuthFailureReason.emailInUse,
  'weak-password' => AuthFailureReason.weakPassword,
  'user-disabled' => AuthFailureReason.disabled,
  'network-request-failed' => AuthFailureReason.network,
  'too-many-requests' => AuthFailureReason.limited,
  'operation-not-allowed' => AuthFailureReason.provider,
  _ => AuthFailureReason.unknown,
};

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this.auth);
  final sdk.FirebaseAuth auth;
  AuthUser? _user(sdk.User? value) => value == null ? null : AuthUser(value.uid,value.email ?? '',value.displayName);
  @override
  AuthUser? get currentUser => _user(auth.currentUser);
  @override
  Stream<AuthUser?> authStateChanges() => auth.authStateChanges().map(_user);
  Future<T> _call<T>(Future<T> Function() operation) async {
    try {return await operation();} on sdk.FirebaseAuthException catch(e){throw AuthException(mapAuthCode(e.code));}
  }
  AuthUser _result(sdk.UserCredential credential) => _user(credential.user) ?? (throw const AuthException(AuthFailureReason.unknown));
  @override
  Future<AuthUser> signIn(String email,String password) => _call(() async => _result(await auth.signInWithEmailAndPassword(email:email.trim(),password:password)));
  @override
  Future<AuthUser> register(String email,String password) => _call(() async => _result(await auth.createUserWithEmailAndPassword(email:email.trim(),password:password)));
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {await auth.sendPasswordResetEmail(email:email.trim());}
    on sdk.FirebaseAuthException catch(e){
      if(e.code!='user-not-found'){throw AuthException(mapAuthCode(e.code));}
    }
  }
  @override
  Future<void> signOut() => _call(auth.signOut);
}
