import '../entities/category_entity.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getCategories(TransactionType type);
  Future<void> createCategory(CategoryEntity category);
  Future<void> updateCategory(CategoryEntity category);
  Future<void> deleteCategory(String id);
  Future<void> updateCategoryOrders(List<CategoryEntity> categories);
}