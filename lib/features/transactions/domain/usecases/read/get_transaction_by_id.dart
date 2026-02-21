import '../../repositories/transaction_repository.dart';
import '../../entities/transaction_entity.dart';

class GetTransactionById {
  final TransactionRepository transactionRepo;

  GetTransactionById(this.transactionRepo);

  Future<TransactionEntity?> call(String id) async {
    return await transactionRepo.getTransactionById(id);
  }
}