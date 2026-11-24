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

  Movement copyWith({String? description, String? category, DateTime? date,
      int? cents, MovementType? type}) => Movement(id, description ?? this.description,
      category ?? this.category, date ?? this.date, cents ?? this.cents, type ?? this.type);

  @override
  List<Object> get props => [id, description, category, date, cents, type];
}
