import '../../domain/entities/movement.dart';
import '../../domain/entities/wallet_summary.dart';
import '../../domain/repositories/wallet_repository.dart';

class InMemoryWalletRepository implements WalletRepository {
  InMemoryWalletRepository({
    this.latency = const Duration(milliseconds: 650),
    bool failFirstLoad = false,
  }) : _failNextLoad = failFirstLoad;

  final Duration latency;
  bool _failNextLoad;

  @override
  Future<WalletSummary> fetchSummary() async {
    await Future<void>.delayed(latency);
    if (_failNextLoad) {
      _failNextLoad = false;
      throw Exception('Fallo simulado para la evidencia del reto 3.');
    }
    return WalletSummary([
      Movement(
        'Plan de internet',
        'Servicios',
        DateTime(2026, 11, 7),
        8990,
        MovementType.expense,
      ),
      Movement(
        'Almuerzo en el comedor',
        'Alimentación',
        DateTime(2026, 11, 6),
        750,
        MovementType.expense,
      ),
      Movement(
        'Pasajes al campus',
        'Transporte',
        DateTime(2026, 11, 6),
        4800,
        MovementType.expense,
      ),
      Movement(
        'Venta de apuntes',
        'Ingreso extra',
        DateTime(2026, 11, 5),
        12000,
        MovementType.income,
      ),
      Movement(
        'Pensión universitaria',
        'Educación',
        DateTime(2026, 11, 4),
        35000,
        MovementType.expense,
      ),
      Movement(
        'Beca de comedor',
        'Beca',
        DateTime(2026, 11, 3),
        45000,
        MovementType.income,
      ),
      Movement(
        'Sueldo de prácticas',
        'Trabajo',
        DateTime(2026, 11, 2),
        120000,
        MovementType.income,
      ),
    ]);
  }
}
