import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/category_entity.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../domain/usecases/read/get_categories.dart';
import '../../domain/usecases/write/create_category.dart';
import '../../domain/usecases/write/update_category.dart';
import '../../domain/usecases/write/delete_category.dart';
import '../../domain/usecases/init_default_categories.dart';
import '../../domain/usecases/update_category_orders.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategories getCategories;
  final InitDefaultCategories initDefaultCategories;
  final CreateCategory createCategory;
  final UpdateCategory updateCategory;
  final DeleteCategory deleteCategory;
  final UpdateCategoryOrders updateCategoryOrders;

  CategoryBloc({
    required this.getCategories,
    required this.initDefaultCategories,
    required this.createCategory,
    required this.updateCategory,
    required this.deleteCategory,
    required this.updateCategoryOrders
  }) : super(CategoryInitial()) {

    // 處理：初始化分類
    on<InitializeDefaultCategoriesEvent>((event, emit) async {
      try {
        await initDefaultCategories();
        // 初始化完畢後，不一定要發送 loaded，因為通常是背景執行
      } catch (e) {
        emit(CategoryError("初始化分類失敗: $e"));
      }
    });

    // 處理：載入分類列表
    on<LoadCategoriesEvent>((event, emit) async {
      emit(CategoryLoading());
      try {
        final categories = await getCategories(event.type);
        emit(CategoryLoaded(categories));
      } catch (e) {
        emit(CategoryError("無法載入分類: $e"));
      }
    });

    // 處理： 創建分類列表
    on<AddCategoryEvent>((event, emit) async {
      try {
        await createCategory(event.category);
        add(LoadCategoriesEvent(event.category.type));
      } catch (e) {
        emit(CategoryError("新增分類失敗: $e"));
      }
    });

    // 處理：更新分類列表
    on<UpdateCategoryEvent>((event, emit) async {
      try {
        await updateCategory(event.category);
        add(LoadCategoriesEvent(event.category.type));
      } catch (e) {
        emit(CategoryError("更新分類失敗: $e"));
      }
    });

    // 處理：刪除分類列表
    on<DeleteCategoryEvent>((event, emit) async {
      try {
        await deleteCategory(event.categoryId);
        add(LoadCategoriesEvent(event.type));
      } catch (e) {
        emit(CategoryError("刪除分類失敗: $e"));
      }
    });

    // 處理：重排列表
    on<ReorderCategoriesEvent>((event, emit) async {
      emit(CategoryLoaded(event.updatedCategories));
      try {
        // 先在背景發送批次更新給 Firebase
        await updateCategoryOrders(event.updatedCategories);
        // 更新完後重新載入確保一致性
        add(LoadCategoriesEvent(event.type));
      } catch (e) {
        emit(CategoryError("排序更新失敗: $e"));
      }
    });
  }

  // TODO: 將註冊列表移出
}