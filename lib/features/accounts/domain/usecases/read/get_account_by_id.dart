import '../../repositories/account_repository.dart';
import '../../entities/account_entity.dart';

class GetAccountById {
  final AccountRepository accountRepo;

  GetAccountById(this.accountRepo);

  Future<AccountEntity?> call(String id) async {
    return await accountRepo.getAccountById(id);
  }
}