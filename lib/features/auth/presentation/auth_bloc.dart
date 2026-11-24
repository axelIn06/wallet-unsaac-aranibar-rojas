import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

sealed class AuthEvent {const AuthEvent();}
final class AuthStarted extends AuthEvent {const AuthStarted();}
final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested(this.email,this.password);
  final String email,password;
}
final class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested(this.email,this.password);
  final String email,password;
}
final class AuthPasswordResetRequested extends AuthEvent {
  const AuthPasswordResetRequested(this.email);
  final String email;
  static const confirmation='Si el correo está registrado, recibirás instrucciones para recuperar tu contraseña.';
}
final class AuthNameRequested extends AuthEvent {
  const AuthNameRequested(this.name);
  final String name;
}
final class AuthLoginPromptRequested extends AuthEvent {const AuthLoginPromptRequested();}
final class AuthLogoutRequested extends AuthEvent {const AuthLogoutRequested();}
sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}
final class AuthInitial extends AuthState {const AuthInitial();}
final class AuthLoading extends AuthState {const AuthLoading();}
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user,[this.message]);
  final AuthUser user;
  final String? message;
  @override
  List<Object?> get props => [user,message];
}
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated([this.message]);
  final String? message;
  @override
  List<Object?> get props => [message];
}
class AuthBloc extends Bloc<AuthEvent,AuthState> {
  AuthBloc(this.repository):super(const AuthInitial()){
    on<AuthStarted>((_,emit) async{
      if(_watching)return;
      _watching=true;
      emit(const AuthLoading());
      await emit.forEach<AuthUser?>(repository.authStateChanges(),
        onData:_sessionChanged,
        onError:(_,_)=>_result(AuthFailureReason.network.message));
    });
    on<AuthLoginRequested>((e,emit)=>_run(emit,() => repository.signIn(e.email,e.password)));
    on<AuthRegisterRequested>((e,emit)=>_run(emit,()=>repository.register(e.email,e.password)));
    on<AuthPasswordResetRequested>((e,emit)=>_run(emit,()=>repository.sendPasswordResetEmail(e.email),success:AuthPasswordResetRequested.confirmation));
    on<AuthNameRequested>((e,emit) async {
      if(_busy)return;
      _busy=true;
      emit(const AuthLoading());
      try {
        final updated=await repository.updateDisplayName(e.name);
        if(!emit.isDone && repository.currentUser?.uid==updated.uid)emit(AuthAuthenticated(updated));
      } on AuthException catch(e){if(!emit.isDone)emit(_result(e.reason.message));}
      catch(_){if(!emit.isDone)emit(_result(AuthFailureReason.unknown.message));}
      finally{_busy=false;}
    });
    on<AuthLoginPromptRequested>((_,emit){
      if(repository.currentUser==null)emit(const AuthUnauthenticated());
    });
    on<AuthLogoutRequested>((_,emit) async{
      if(_busy || repository.currentUser==null)return;
      _intentional=true;
      await _run(emit,repository.signOut,success:signedOut);
      if(repository.currentUser!=null)_intentional=false;
    });
  }
  final AuthRepository repository;
  static const expired='Tu sesión expiró.';
  static const signedOut='Cerraste sesión.';
  AuthUser? _observed;
  bool _intentional=false;
  AuthState _sessionChanged(AuthUser? user){
    final previous=_observed;
    _observed=user;
    if(user!=null)return AuthAuthenticated(user);
    if(previous==null && state is AuthUnauthenticated)return state;
    final message=_intentional ? signedOut : (previous==null ? null : expired);
    _intentional=false;
    return AuthUnauthenticated(message);
  }
  bool _watching=false, _busy=false;
  AuthState _result([String? message]){
    final user=repository.currentUser;
    return user==null ? AuthUnauthenticated(message) : AuthAuthenticated(user,message);
  }
  Future<void> _run(Emitter<AuthState> emit, Future<void> Function() operation,{String? success}) async{
    if(_busy)return;
    _busy=true;
    emit(const AuthLoading());
    try {await operation(); if(!emit.isDone)emit(_result(success));}
    on AuthException catch(e){if(!emit.isDone)emit(_result(e.reason.message));}
    catch(_){if(!emit.isDone)emit(_result(AuthFailureReason.unknown.message));}
    finally{_busy=false;}
  }
}
