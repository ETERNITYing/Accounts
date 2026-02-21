import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<void> addTransaction(TransactionEntity transactionEntity_);
  Future<void> deleteTransaction(String id);
  Future<void> updateTransaction(TransactionEntity transactionEntity_);
  Future<List<TransactionEntity>> getDailyTransactions(DateTime date);
  Future<List<TransactionEntity>> getTransactionsByDate(DateTime startOfDay, DateTime endOfDay);
  Future<TransactionEntity?> getTransactionById(String id);
}