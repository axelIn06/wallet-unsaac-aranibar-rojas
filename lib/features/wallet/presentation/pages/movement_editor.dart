import 'package:flutter/material.dart';
import '../../domain/entities/movement.dart';

class MovementEditor extends StatefulWidget {
  const MovementEditor(this.movement, {super.key});
  final Movement movement;
  @override
  State<MovementEditor> createState() => _MovementEditorState();
}
class _MovementEditorState extends State<MovementEditor> {
  final _form = GlobalKey<FormState>();
  late String title = widget.movement.description;
  late String amount = (widget.movement.cents / 100).toStringAsFixed(2);

  int? cents(String input) {
    final parts = input.trim().replaceAll(',', '.');
    if (!RegExp(r'^\d{1,9}(\.\d{1,2})?$').hasMatch(parts)) return null;
    final digits = parts.split('.');
    return int.parse(digits.first) * 100 +
        (digits.length == 1 ? 0 : int.parse(digits.last.padRight(2,'0')));
  }
  @override
  Widget build(BuildContext context) => AlertDialog(title: const Text('Editar movimiento'),
    content: SingleChildScrollView(child: Form(key: _form, child: Column(mainAxisSize: MainAxisSize.min,children:[
      TextFormField(initialValue: title, decoration: const InputDecoration(labelText: 'Título'),
        onChanged: (value) => title=value.trim(), validator: (value) => (value ?? '').trim().isEmpty ? 'Escribe un título' : null),
      TextFormField(initialValue: amount, decoration: const InputDecoration(labelText: 'Monto en soles'),
        keyboardType: const TextInputType.numberWithOptions(decimal:true), onChanged:(value)=>amount=value,
        validator: (value) => (cents(value ?? '') ?? 0) > 0 ? null : 'Usa un monto positivo con hasta dos decimales'),
    ]))), actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancelar')),
      FilledButton(onPressed:(){if(_form.currentState!.validate()){
        Navigator.pop(context,widget.movement.copyWith(description:title,cents:cents(amount)!));
      }},child:const Text('Guardar'))]);
}
