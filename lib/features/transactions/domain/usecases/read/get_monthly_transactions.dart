import '../../repositories/transaction_repository.dart';
import '../../entities/transaction_entity.dart';

class GetMonthlyTransactions {
  final TransactionRepository transactionRepo;

  GetMonthlyTransactions(this.transactionRepo);

  Future<List<TransactionEntity>> call(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0);

    return await transactionRepo.getTransactionsByDate(start, end);
  }
}