import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_bloc.dart';
import 'auth_form.dart';
import '../domain/auth_user.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.wallet,required this.local});
  final Widget Function(AuthUser) wallet;
  final bool local;
  @override
  Widget build(BuildContext context)=>BlocConsumer<AuthBloc,AuthState>(
    listener:(context,state){
      final message=switch(state){AuthAuthenticated(:final message)||AuthUnauthenticated(:final message)=>message,_=>null};
      if(message!=null){
        final messenger=ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(SnackBar(content:Text(message)));
      }
    },
    buildWhen:(previous,current)=>current is! AuthLoading,
    builder:(_,state)=>switch(state){
      AuthAuthenticated(:final user)=>wallet(user),
      AuthUnauthenticated()=>AuthForm(local:local),
      _=>const Scaffold(body:Center(child:CircularProgressIndicator())),
    },
  );
}
