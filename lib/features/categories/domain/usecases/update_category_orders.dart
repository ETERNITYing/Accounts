import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class UpdateCategoryOrders {
  final CategoryRepository repository;
  UpdateCategoryOrders(this.repository);

  Future<void> call(List<CategoryEntity> categories) async {
    return await repository.updateCategoryOrders(categories);
  }
}