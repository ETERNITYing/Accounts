import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_data_source.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> addTransaction(TransactionEntity transactionEntity_) async {
    try {
      final tTransactionRecordModel = TransactionModel(
        id: transactionEntity_.id,
        accountId: transactionEntity_.accountId,
        amount: transactionEntity_.amount,
        date: transactionEntity_.date,
        note: transactionEntity_.note,
        type: transactionEntity_.type,
        categoryId: transactionEntity_.categoryId,
        userId: transactionEntity_.userId,
      );

      await remoteDataSource.addTransaction(tTransactionRecordModel);
    } catch (e) {
      // 這裡應該要把錯誤包裝成 Failure 回傳 (視您的錯誤處理策略而定)
      throw Exception('ERROR!! Create failed: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await remoteDataSource.deleteTransaction(id);
    } catch(e) {
      throw Exception('ERROR!! Delete failed: $e');
    }
  }

  @override
  Future<void> updateTransaction(TransactionEntity transactionEntity_) async {
    try {
      final tTransactionRecordModel = TransactionModel(
        id: transactionEntity_.id,
        accountId: transactionEntity_.accountId,
        amount: transactionEntity_.amount,
        date: transactionEntity_.date,
        note: transactionEntity_.note,
        type: transactionEntity_.type,
        categoryId: transactionEntity_.categoryId,
        userId: transactionEntity_.userId,
      );
      await remoteDataSource.updateTransaction(tTransactionRecordModel);
    } catch (e) {
      throw Exception('ERROR!! Update failed: $e');
    }
  }

  @override
  Future<List<TransactionEntity>> getDailyTransactions(DateTime date) async {
    try {
      final models = await remoteDataSource.getDailyTransactions(date);
      return models;
    } catch(e) {
      throw Exception('ERROR!! Read failed: $e');
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByDate(DateTime startOfDay, DateTime endOfDay) async {
    try {
      final models = await remoteDataSource.getTransactionsByDate(startOfDay, endOfDay);
      return models;
    } catch(e) {
      throw Exception('ERROR!! Read failed: $e');
    }
  }

  @override
  Future<TransactionEntity?> getTransactionById(String id) async {
    try {
      final models = await remoteDataSource.getTransactionById(id);
      return models;
    } catch(e) {
      throw Exception('ERROR!! Read failed: $e');
    }
  }
}