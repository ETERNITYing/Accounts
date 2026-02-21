import '../../repositories/transaction_repository.dart';
import '../../../../accounts/domain/repositories/account_repository.dart';
import '../../entities/transaction_entity.dart';

class DeleteTransaction {
  final TransactionRepository transactionRepo;
  final AccountRepository accountRepo;

  DeleteTransaction(this.transactionRepo, this.accountRepo);

  Future<void> call(String id) async {
    final transactionEntity_ = await transactionRepo.getTransactionById(id);

    if(transactionEntity_ == null) {
      return;
    } else {
      if (transactionEntity_.type == TransactionType.expense) {
        await accountRepo.updateBalance(transactionEntity_.accountId, transactionEntity_.amount);
      } else {
        await accountRepo.updateBalance(transactionEntity_.accountId, -transactionEntity_.amount);
      }
      await transactionRepo.deleteTransaction(id);
    }
  }
}