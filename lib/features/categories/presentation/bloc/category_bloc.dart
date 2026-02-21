import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/category_entity.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../domain/usecases/read/get_categories.dart';
import '../../domain/usecases/init_default_categories.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategories getCategories;
  final InitDefaultCategories initDefaultCategories;

  CategoryBloc({
    required this.getCategories,
    required this.initDefaultCategories,
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
  }
}