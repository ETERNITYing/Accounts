import '../../repositories/transaction_repository.dart';
import '../../entities/transaction_entity.dart';

class GetDailyTransactions {
  final TransactionRepository transactionRepo;

  GetDailyTransactions(this.transactionRepo);

  Future<List<TransactionEntity>> call(DateTime date) async {
    return await transactionRepo.getDailyTransactions(date);
  }
}