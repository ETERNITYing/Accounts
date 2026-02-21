import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_data_source.dart';
import '../models/category_model.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CategoryEntity>> getCategories(TransactionType type) async {
    try {
      return await remoteDataSource.getCategories(type);
    } catch (e) {
      throw Exception('ERROR! Fetch Categories Fail: $e');
    }
  }

  @override
  Future<void> createCategory(CategoryEntity category) async {
    try {
      final model = CategoryModel.fromEntity(category);
      await remoteDataSource.createCategory(model);
    } catch (e) {
      throw Exception('ERROR! Create Categories Fail:: $e');
    }
  }

  @override
  Future<void> updateCategory(CategoryEntity category) async {
    try {
      final model = CategoryModel.fromEntity(category);
      await remoteDataSource.updateCategory(model);
    } catch (e) {
      throw Exception('ERROR! Update Categories Fail:: $e');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await remoteDataSource.deleteCategory(id);
    } catch (e) {
      throw Exception('ERROR! Delete Categories Fail:: $e');
    }
  }

  @override
  Future<void> updateCategoryOrders(List<CategoryEntity> categories) async {
    try {
      final models = categories.map((entity) => CategoryModel.fromEntity(entity)).toList();
      await remoteDataSource.updateCategoryOrders(models);
    } catch (e) {
      throw Exception('ERROR! Update Category Orders Fail: $e');
    }
  }
}