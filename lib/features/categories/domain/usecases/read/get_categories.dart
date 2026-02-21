import '../../entities/category_entity.dart';
import '../../repositories/category_repository.dart';
import '../../../../transactions/domain/entities/transaction_entity.dart';

class GetCategories {
  final CategoryRepository repository;

  GetCategories(this.repository);

  // 傳入 type (收入或支出)，因為記帳時通常只會顯示對應的分類
  Future<List<CategoryEntity>> call(TransactionType type) async {
    return await repository.getCategories(type);
  }
}