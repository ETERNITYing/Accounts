import '../../entities/category_entity.dart';
import '../../repositories/category_repository.dart';

class CreateCategory {
  final CategoryRepository repository;
  CreateCategory(this.repository);

  Future<void> call(CategoryEntity category) async {
    return await repository.createCategory(category);
  }
}