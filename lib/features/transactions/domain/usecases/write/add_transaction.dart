import '../../repositories/transaction_repository.dart';
import '../../../../accounts/domain/repositories/account_repository.dart';
import '../../entities/transaction_entity.dart';

class AddTransaction {
  final TransactionRepository transactionRepo;
  final AccountRepository accountRepo;

  AddTransaction(this.transactionRepo, this.accountRepo);

  Future<void> call(TransactionEntity transactionEntity_) async {
    await transactionRepo.addTransaction(transactionEntity_);

    if (transactionEntity_.type == TransactionType.expense) {
      await accountRepo.updateBalance(transactionEntity_.accountId, -transactionEntity_.amount);
    } else {
      await accountRepo.updateBalance(transactionEntity_.accountId, transactionEntity_.amount);
    }
  }
}