import 'package:equatable/equatable.dart';

enum MovementType { income, expense }

class Movement extends Equatable {
  const Movement(
    this.id,
    this.description,
    this.category,
    this.date,
    this.cents,
    this.type,
  );

  final String id;
  final String description;
  final String category;
  final DateTime date;
  final int cents;
  final MovementType type;

  @override
  List<Object> get props => [id, description, category, date, cents, type];
}
