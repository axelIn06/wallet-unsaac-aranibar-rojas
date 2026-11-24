import 'dart:async';
import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

class InMemoryAuthRepository implements AuthRepository {
  // Cuenta ficticia publicada en la guía, solo para la práctica en memoria.
  static const demoEmail = 'estudiante@unsaac.edu.pe';
  static const demoPassword = 'wallet123';
  final _accounts = <String,({AuthUser user,String password})>{
    demoEmail:(user:const AuthUser('demo-1',demoEmail),password:demoPassword),
  };
  final _changes = StreamController<AuthUser?>.broadcast();
  AuthUser? _current;
  @override
  AuthUser? get currentUser => _current;
  @override
  Stream<AuthUser?> authStateChanges() => Stream.multi((sink){
    final sub = _changes.stream.listen(sink.addSync,onDone:sink.closeSync);
    sink.addSync(_current);
    sink.onCancel=sub.cancel;
  });
  void _setUser(AuthUser? value){_current=value;_changes.add(value);}
  @override
  Future<AuthUser> signIn(String email,String password) async {
    final account=_accounts[email.trim().toLowerCase()];
    if(account==null || account.password!=password){throw const AuthException(AuthFailureReason.invalidCredentials);}
    _setUser(account.user);return account.user;
  }
  @override
  Future<AuthUser> register(String email,String password) async {
    final key=email.trim().toLowerCase();
    if (_accounts.containsKey(key)){throw const AuthException(AuthFailureReason.emailInUse);}
    if(password.length<6){throw const AuthException(AuthFailureReason.weakPassword);}
    final user=AuthUser('demo-'+(_accounts.length+1).toString(),key);
    _accounts[key]=(user:user,password:password);_setUser(user);return user;
  }
  @override
  Future<void> signOut() async => _setUser(null);
}
