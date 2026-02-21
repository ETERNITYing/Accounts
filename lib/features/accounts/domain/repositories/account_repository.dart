import '../entities/account_entity.dart';

abstract class AccountRepository {
  Future<List<AccountEntity>> getAccounts();
  Future<AccountEntity?> getAccountById(String id);
  Future<void> createAccount(AccountEntity account);
  Future<void> updateAccount(AccountEntity account);
  Future<void> deleteAccount(String id);
  Future<void> updateBalance(String accountId, double amount);
}