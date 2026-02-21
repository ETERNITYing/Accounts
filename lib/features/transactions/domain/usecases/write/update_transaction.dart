import '../../repositories/transaction_repository.dart';
import '../../../../accounts/domain/repositories/account_repository.dart';
import '../../entities/transaction_entity.dart';

class UpdateTransaction {
  final TransactionRepository transactionRepo;
  final AccountRepository accountRepo;

  UpdateTransaction(this.transactionRepo, this.accountRepo);

  Future<void> call(TransactionEntity transactionEntity_) async {
// 把舊資料撈出來
    final oldTransaction = await transactionRepo.getTransactionById(transactionEntity_.id);

    if (oldTransaction != null) {
      // 把舊紀錄的錢退還給舊帳戶
      if (oldTransaction.type == TransactionType.expense) {
        await accountRepo.updateBalance(oldTransaction.accountId, oldTransaction.amount); // 支出退還 (+)
      } else {
        await accountRepo.updateBalance(oldTransaction.accountId, -oldTransaction.amount); // 收入退還 (-)
      }
    }

    // 把新紀錄的錢扣除/增加給新帳戶
    if (transactionEntity_.type == TransactionType.expense) {
      await accountRepo.updateBalance(transactionEntity_.accountId, -transactionEntity_.amount); // 支出扣款 (-)
    } else {
      await accountRepo.updateBalance(transactionEntity_.accountId, transactionEntity_.amount); // 收入加款 (+)
    }

    // 最後更新交易紀錄本身
    await transactionRepo.updateTransaction(transactionEntity_);
  }
}