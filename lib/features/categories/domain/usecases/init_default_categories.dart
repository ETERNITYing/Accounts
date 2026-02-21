import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

class InitDefaultCategories {
  final CategoryRepository repository;

  InitDefaultCategories(this.repository);

  Future<void> call() async {
    // 先檢查使用者是不是已經有「支出」分類了
    final existingExpenses = await repository.getCategories(TransactionType.expense);

    // 如果已經有資料，代表已經初始化過了，直接Return
    if (existingExpenses.isNotEmpty) {
      print('分類庫已存在，跳過初始化。');
      return;
    }

    print('偵測到新帳號，開始建立預設分類...');

    // 預設分類
    final defaultCategories = [
      // --- 支出 ---
      const CategoryEntity(id: '', name: '飲食', iconCode: 'restaurant', colorValue: 0xFFFF9800, type: TransactionType.expense, userId: ''),
      const CategoryEntity(id: '', name: '交通', iconCode: 'directions_car', colorValue: 0xFF2196F3, type: TransactionType.expense, userId: ''),
      const CategoryEntity(id: '', name: '購物', iconCode: 'shopping_cart', colorValue: 0xFFE91E63, type: TransactionType.expense, userId: ''),
      const CategoryEntity(id: '', name: '娛樂', iconCode: 'movie', colorValue: 0xFF9C27B0, type: TransactionType.expense, userId: ''),
      const CategoryEntity(id: '', name: '居家', iconCode: 'home', colorValue: 0xFF4CAF50, type: TransactionType.expense, userId: ''),
      const CategoryEntity(id: '', name: '醫療', iconCode: 'local_hospital', colorValue: 0xFFF44336, type: TransactionType.expense, userId: ''),
      const CategoryEntity(id: '', name: '其他', iconCode: 'more_horiz', colorValue: 0xFF9E9E9E, type: TransactionType.expense, userId: ''),

      // --- 收入 ---
      const CategoryEntity(id: '', name: '薪水', iconCode: 'attach_money', colorValue: 0xFF8BC34A, type: TransactionType.income, userId: ''),
      const CategoryEntity(id: '', name: '投資', iconCode: 'trending_up', colorValue: 0xFFFFC107, type: TransactionType.income, userId: ''),
      const CategoryEntity(id: '', name: '獎金', iconCode: 'card_giftcard', colorValue: 0xFF00BCD4, type: TransactionType.income, userId: ''),
      const CategoryEntity(id: '', name: '其他收入', iconCode: 'add_circle_outline', colorValue: 0xFF9E9E9E, type: TransactionType.income, userId: ''),
    ];

    // 用迴圈一筆一筆存進 Firebase
    final futures = defaultCategories.map((category) => repository.createCategory(category));
    await Future.wait(futures);

    print('預設分類初始化完成！');
  }
}