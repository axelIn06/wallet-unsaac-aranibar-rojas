import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/auth_user.dart';
import 'auth_bloc.dart';

class AccountMenu extends StatelessWidget {
  const AccountMenu(this.user, {super.key});
  final AuthUser user;
  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    tooltip: 'Cuenta de ${user.label}',
    icon: CircleAvatar(child: Text(user.label.characters.first.toUpperCase())),
    itemBuilder: (_) => [
      PopupMenuItem<String>(enabled: false, child: Text(user.email)),
      const PopupMenuItem(value: 'name', child: Text('Editar nombre')),
      const PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
    ],
    onSelected: (action) async {
      final bloc = context.read<AuthBloc>();
      if (action == 'name') {
        final name = await showDialog<String>(
          context: context,
          builder: (_) => _NameDialog(user.displayName ?? ''),
        );
        if (name != null &&
            !bloc.isClosed &&
            bloc.repository.currentUser?.uid == user.uid) {
          bloc.add(AuthNameRequested(name));
        }
      } else {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('¿Cerrar sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Salir'),
              ),
            ],
          ),
        );
        if (confirm == true &&
            !bloc.isClosed &&
            bloc.repository.currentUser?.uid == user.uid) {
          bloc.add(const AuthLogoutRequested());
        }
      }
    },
  );
}

class _NameDialog extends StatefulWidget {
  const _NameDialog(this.initial);
  final String initial;
  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late String name = widget.initial;
  final form = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Editar nombre'),
    content: Form(
      key: form,
      child: TextFormField(
        initialValue: name,
        maxLength: 48,
        decoration: const InputDecoration(labelText: 'Nombre para mostrar'),
        onChanged: (v) => name = v.trim(),
        validator: (_) =>
            name.isEmpty ? 'Escribe un nombre para mostrar.' : null,
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () {
          if (form.currentState!.validate()) Navigator.pop(context, name);
        },
        child: const Text('Guardar'),
      ),
    ],
  );
}
