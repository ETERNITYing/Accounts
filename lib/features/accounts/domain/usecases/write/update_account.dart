import '../../entities/account_entity.dart';
import '../../repositories/account_repository.dart';

class UpdateAccount {
  final AccountRepository repository;

  UpdateAccount(this.repository);

  Future<void> call(AccountEntity account) async {
    return await repository.updateAccount(account);
  }
}