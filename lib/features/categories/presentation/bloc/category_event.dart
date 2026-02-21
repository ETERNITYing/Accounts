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