import '../entities/movement.dart';
import '../entities/wallet_summary.dart';

abstract interface class WalletRepository {
  Future<WalletSummary> fetchSummary();
  Future<WalletSummary> addMovement(Movement movement);
  Future<WalletSummary> removeMovement(String id);
  Future<WalletSummary> updateMovement(Movement movement);
  Future<WalletSummary> clearMovements();
}
