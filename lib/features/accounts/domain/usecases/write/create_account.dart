import '../../entities/account_entity.dart';
import '../../repositories/account_repository.dart';

class CreateAccount {
  final AccountRepository repository;

  CreateAccount(this.repository);

  Future<void> call(AccountEntity account) async {
    return await repository.createAccount(account);
  }
}