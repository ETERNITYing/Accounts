import '../../repositories/account_repository.dart';
import '../../entities/account_entity.dart';

class GetAccounts {
  final AccountRepository accountRepo;

  GetAccounts(this.accountRepo);

  Future<List<AccountEntity>> call() async {
    return await accountRepo.getAccounts();
  }
}