enum MovementType { income, expense }

class Movement {
  const Movement(
    this.description,
    this.category,
    this.date,
    this.cents,
    this.type,
  );

  final String description;
  final String category;
  final DateTime date;
  final int cents;
  final MovementType type;
}
