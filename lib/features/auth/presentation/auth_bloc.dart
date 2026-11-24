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
        onData:(user)=>user==null ? const AuthUnauthenticated() : AuthAuthenticated(user),
        onError:(_,_)=>_result(AuthFailureReason.network.message));
    });
    on<AuthLoginRequested>((e,emit)=>_run(emit,() => repository.signIn(e.email,e.password)));
    on<AuthRegisterRequested>((e,emit)=>_run(emit,()=>repository.register(e.email,e.password)));
    on<AuthLogoutRequested>((_,emit)=>_run(emit,repository.signOut));
  }
  final AuthRepository repository;
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
