import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_bloc.dart';

class AuthValidators {
  static String? email(String? value) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value?.trim() ?? '') ? null : 'Ingresa un correo válido.';
  static String? password(String? value) => (value?.length ?? 0)>=6 ? null : 'Usa al menos 6 caracteres.';
  static String? confirmation(String? value,String original) => value==original && original.isNotEmpty ? null : 'Las contraseñas deben coincidir.';
}
enum _FormMode { login, register, reset }
class AuthForm extends StatefulWidget {
  const AuthForm({super.key, required this.local});
  final bool local;
  @override
  State<AuthForm> createState()=>_AuthFormState();
}
class _AuthFormState extends State<AuthForm>{
  final _key=GlobalKey<FormState>();
  final _email=TextEditingController(), _password=TextEditingController(), _confirmation=TextEditingController();
  _FormMode mode=_FormMode.login;
  @override
  void dispose(){_email.dispose();_password.dispose();_confirmation.dispose();super.dispose();}
  void change(_FormMode value){_key.currentState?.reset();_password.clear();_confirmation.clear();setState(()=>mode=value);}
  void submit(){
    if(!_key.currentState!.validate())return;
    FocusScope.of(context).unfocus();
    final email=_email.text.trim();
    context.read<AuthBloc>().add(switch(mode){
      _FormMode.login=>AuthLoginRequested(email,_password.text),
      _FormMode.register=>AuthRegisterRequested(email,_password.text),
      _FormMode.reset=>AuthPasswordResetRequested(email),
    });
  }
  @override
  Widget build(BuildContext context){
    final busy=context.select((AuthBloc b)=>b.state is AuthLoading);
    final title=switch(mode){_FormMode.login=>'Iniciar sesión',_FormMode.register=>'Crear cuenta',_FormMode.reset=>'Recuperar contraseña'};
    return Scaffold(appBar:AppBar(title:const Text('Wallet UNSAAC')),body:SafeArea(child:Center(child:SingleChildScrollView(
      padding:const EdgeInsets.all(20),child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:420),
      child:Card(child:Padding(padding:const EdgeInsets.all(22),child:Form(key:_key,child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        Icon(Icons.account_balance_wallet_outlined,size:40,color:Theme.of(context).colorScheme.primary),
        const SizedBox(height:12),Text(title,style:Theme.of(context).textTheme.headlineSmall,textAlign:TextAlign.center),
        if(widget.local)const Text('Práctica en memoria',textAlign:TextAlign.center),
        const SizedBox(height:20),
        TextFormField(controller:_email,keyboardType:TextInputType.emailAddress,autocorrect:false,decoration:const InputDecoration(labelText:'Correo electrónico'),validator:AuthValidators.email),
        if(mode!=_FormMode.reset)TextFormField(controller:_password,obscureText:true,enableSuggestions:false,autocorrect:false,decoration:const InputDecoration(labelText:'Contraseña'),validator:AuthValidators.password),
        if(mode==_FormMode.register)TextFormField(controller:_confirmation,obscureText:true,enableSuggestions:false,autocorrect:false,decoration:const InputDecoration(labelText:'Confirmar contraseña'),validator:(v)=>AuthValidators.confirmation(v,_password.text)),
        const SizedBox(height:16),
        FilledButton(onPressed:busy?null:submit,child:busy?const SizedBox.square(dimension:20,child:CircularProgressIndicator(strokeWidth:2)):Text(mode==_FormMode.reset?'Solicitar instrucciones':title)),
        if(mode==_FormMode.login)...[
          TextButton(onPressed:busy?null:()=>change(_FormMode.reset),child:const Text('¿Olvidaste tu contraseña?')),
          OutlinedButton(onPressed:busy?null:()=>change(_FormMode.register),child:const Text('Registrarme')),
        ] else TextButton(onPressed:busy?null:()=>change(_FormMode.login),child:const Text('Volver al acceso')),
      ])))))))));
  }
}
