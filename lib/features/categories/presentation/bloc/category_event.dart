part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object> get props => [];
}

// 載入分類 (需要告訴 Bloc 要載入收入還是支出)
class LoadCategoriesEvent extends CategoryEvent {
  final TransactionType type;
  const LoadCategoriesEvent(this.type);

  @override
  List<Object> get props => [type];
}

// 初始化預設分類
class InitializeDefaultCategoriesEvent extends CategoryEvent {}

class AddCategoryEvent extends CategoryEvent {
  final CategoryEntity category;
  const AddCategoryEvent(this.category);
  @override
  List<Object> get props => [category];
}

class UpdateCategoryEvent extends CategoryEvent {
  final CategoryEntity category;
  const UpdateCategoryEvent(this.category);
  @override
  List<Object> get props => [category];
}

class DeleteCategoryEvent extends CategoryEvent {
  final String categoryId;
  final TransactionType type; // 需要知道刪除的是收入還是支出，才能重整對應的列表
  const DeleteCategoryEvent(this.categoryId, this.type);
  @override
  List<Object> get props => [categoryId, type];
}

class ReorderCategoriesEvent extends CategoryEvent {
  final List<CategoryEntity> updatedCategories;
  final TransactionType type; // 為了重整畫面用
  const ReorderCategoriesEvent(this.updatedCategories, this.type);

  @override
  List<Object> get props => [updatedCategories, type];
}