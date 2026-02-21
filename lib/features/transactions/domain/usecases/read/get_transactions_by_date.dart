import '../../repositories/transaction_repository.dart';
import '../../entities/transaction_entity.dart';

class GetTransactionsByDate {
  final TransactionRepository transactionRepo;

  GetTransactionsByDate(this.transactionRepo);

  Future<List<TransactionEntity>> call(DateTime start, DateTime end) async {
    return await transactionRepo.getTransactionsByDate(start, end);
  }
}