import '../../domain/entities/movement.dart';
import '../../domain/entities/wallet_summary.dart';
import '../../domain/repositories/wallet_repository.dart';

class InMemoryWalletRepository implements WalletRepository {
  InMemoryWalletRepository({
    this.latency = const Duration(milliseconds: 650),
    Iterable<Movement>? seed,
    bool failFirstLoad = false,
  }) : _items = List.of(seed ?? _demo), _failNextLoad = failFirstLoad;

  final List<Movement> _items;
  final Duration latency;
  bool _failNextLoad;

  @override
  Future<WalletSummary> fetchSummary() async {
    await Future<void>.delayed(latency);
    if (_failNextLoad) {
      _failNextLoad = false;
      throw Exception('Fallo simulado para la evidencia del reto 3.');
    }
    return WalletSummary(_items);
  }

  @override
  Future<WalletSummary> addMovement(Movement movement) async {
    await Future<void>.delayed(latency);
    if (_items.any((item) => item.id == movement.id)) {
      throw StateError('Identificador repetido');
    }
    _items.insert(0, movement);
    return WalletSummary(_items);
  }
  @override
  Future<WalletSummary> removeMovement(String id) async {
    await Future<void>.delayed(latency);
    _items.removeWhere((item) => item.id == id);
    return WalletSummary(_items);
  }
  @override
  Future<WalletSummary> clearMovements() async {
    await Future<void>.delayed(latency);
    _items.clear();
    return WalletSummary(_items);
  }
  static final _demo = [

      Movement(
        "demo-1",
        'Plan de internet',
        'Servicios',
        DateTime(2026, 11, 7),
        8990,
        MovementType.expense,
      ),
      Movement(
        "demo-2",
        'Almuerzo en el comedor',
        'Alimentación',
        DateTime(2026, 11, 6),
        750,
        MovementType.expense,
      ),
      Movement(
        "demo-3",
        'Pasajes al campus',
        'Transporte',
        DateTime(2026, 11, 6),
        4800,
        MovementType.expense,
      ),
      Movement(
        "demo-4",
        'Venta de apuntes',
        'Ingreso extra',
        DateTime(2026, 11, 5),
        12000,
        MovementType.income,
      ),
      Movement(
        "demo-5",
        'Pensión universitaria',
        'Educación',
        DateTime(2026, 11, 4),
        35000,
        MovementType.expense,
      ),
      Movement(
        "demo-6",
        'Beca de comedor',
        'Beca',
        DateTime(2026, 11, 3),
        45000,
        MovementType.income,
      ),
      Movement(
        "demo-7",
        'Sueldo de prácticas',
        'Trabajo',
        DateTime(2026, 11, 2),
        120000,
        MovementType.income,
      ),
  ];
}
