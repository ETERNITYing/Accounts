import '../models/account_model.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_data_source.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;

  AccountRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> createAccount(AccountEntity account) async {
    try {
      final model = AccountModel.fromEntity(account);
      await remoteDataSource.createAccount(model);
    } catch (e) {
      throw Exception('Create account failed: $e');
    }
  }

  @override
  Future<void> deleteAccount(String id) async {
    try {
      await remoteDataSource.deleteAccount(id);
    } catch (e) {
      throw Exception('Delete account failed: $e');
    }
  }

  @override
  Future<AccountEntity?> getAccountById(String id) async {
    try {
      return await remoteDataSource.getAccountById(id);
    } catch (e) {
      throw Exception('Get account failed: $e');
    }
  }

  @override
  Future<List<AccountEntity>> getAccounts() async {
    try {
      return await remoteDataSource.getAccounts();
    } catch (e) {
      throw Exception('Get accounts failed: $e');
    }
  }

  @override
  Future<void> updateAccount(AccountEntity account) async {
    try {
      final model = AccountModel.fromEntity(account);
      await remoteDataSource.updateAccount(model);
    } catch (e) {
      throw Exception('Update account failed: $e');
    }
  }

  @override
  Future<void> updateBalance(String accountId, double amount) async {
    try {
      // 替換掉原本的假裝延遲，真正呼叫 DataSource 去更新
      await remoteDataSource.updateBalance(accountId, amount);
      print('[AccountRepository] 成功更新帳戶 $accountId 的餘額！金額: $amount');
    } catch (e) {
      throw Exception('Update balance failed: $e');
    }
  }


}