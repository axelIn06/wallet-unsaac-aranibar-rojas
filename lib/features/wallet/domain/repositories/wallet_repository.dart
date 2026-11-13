import '../entities/wallet_summary.dart';

abstract interface class WalletRepository {
  Future<WalletSummary> fetchSummary();
}
