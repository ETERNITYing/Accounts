import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category_entity.dart';
import '../bloc/category_bloc.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

class CategoryManagePage extends StatefulWidget {
  const CategoryManagePage({super.key});

  @override
  State<CategoryManagePage> createState() => _CategoryManagePageState();
}

class _CategoryManagePageState extends State<CategoryManagePage> {
  bool _isExpense = true; // 預設看支出分類

  // 預設提供一些顏色給使用者選
  final List<Color> _colorOptions = const [
    Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
    Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
    Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
    Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
    Colors.brown, Colors.grey, Colors.blueGrey
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    context.read<CategoryBloc>().add(LoadCategoriesEvent(
      _isExpense ? TransactionType.expense : TransactionType.income,
    ));
  }

  // 顯示新增或編輯的 BottomSheet (account 傳 null 代表新增，傳值代表編輯)
  void _showCategoryBottomSheet({CategoryEntity? category}) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: isEditing ? category.name : '');
    TransactionType selectedType = isEditing ? category.type : (_isExpense ? TransactionType.expense : TransactionType.income);
    Color selectedColor = isEditing ? Color(category.colorValue) : _colorOptions[0];

    // 簡化Icon選擇，統一預設Icon
    // TODO: Icon選擇器
    String selectedIconCode = isEditing ? category.iconCode : 'category';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 24, right: 24, top: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isEditing ? '編輯分類' : '新增分類', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        if (isEditing)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('刪除分類'),
                                  content: const Text('確定要刪除嗎？這將不會影響已記帳的紀錄，但未來無法再選擇此分類。'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
                                    TextButton(
                                      onPressed: () {
                                        context.read<CategoryBloc>().add(DeleteCategoryEvent(category.id, category.type));
                                        Navigator.pop(ctx);
                                        Navigator.pop(context);
                                      },
                                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                                      child: const Text('刪除'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 名稱輸入
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: '分類名稱', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),

                    // 類型切換 (編輯時通常不建議改類型，但還是開放)
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<TransactionType>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(value: TransactionType.expense, label: Text('支出')),
                          ButtonSegment(value: TransactionType.income, label: Text('收入')),
                        ],
                        selected: {selectedType},
                        onSelectionChanged: (Set<TransactionType> newSelection) {
                          setModalState(() => selectedType = newSelection.first);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 顏色選擇器
                    const Text('選擇顏色', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _colorOptions.length,
                        itemBuilder: (context, index) {
                          final color = _colorOptions[index];
                          return GestureDetector(
                            onTap: () => setModalState(() => selectedColor = color),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedColor == color ? Theme.of(context).colorScheme.onSurface : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 儲存按鈕
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          if (name.isEmpty) return;

                          // 取得目前分類的總數量
                          int currentListLength = 0;
                          final currentState = context.read<CategoryBloc>().state;
                          if (currentState is CategoryLoaded) {
                            currentListLength = currentState.categories.length;
                          }

                          final newOrUpdatedCategory = CategoryEntity(
                            id: isEditing ? category.id : '',
                            name: name,
                            iconCode: selectedIconCode,
                            colorValue: selectedColor.value, // 存入顏色的 int 值
                            type: selectedType,
                            userId: isEditing ? category.userId : '',
                            sortOrder: isEditing ? category.sortOrder : currentListLength,
                          );

                          if (isEditing) {
                            context.read<CategoryBloc>().add(UpdateCategoryEvent(newOrUpdatedCategory));
                          } else {
                            context.read<CategoryBloc>().add(AddCategoryEvent(newOrUpdatedCategory));
                          }
                          Navigator.pop(context);
                        },
                        child: const Text('儲存分類', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('分類管理')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryBottomSheet(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // 頂部切換開關
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('支出分類')),
                  ButtonSegment(value: false, label: Text('收入分類')),
                ],
                selected: {_isExpense},
                onSelectionChanged: (newSelection) {
                  setState(() => _isExpense = newSelection.first);
                  _loadCategories(); // 切換時重新撈取資料
                },
              ),
            ),
          ),

          // 分類列表
          Expanded(
            child: BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CategoryLoaded) {
                  final categories = state.categories;
                  if (categories.isEmpty) {
                    return const Center(child: Text('尚未建立分類', style: TextStyle(color: Colors.grey)));
                  }
                  return ReorderableListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return ListTile(
                        // ReorderableListView 的子元件必須要有獨一無二的 Key！
                        key: ValueKey(category.id),
                        leading: CircleAvatar(
                          backgroundColor: Color(category.colorValue).withOpacity(0.2),
                          child: Icon(Icons.category, color: Color(category.colorValue)),
                        ),
                        title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        // 右側換成漢堡條圖示，暗示可以拖曳
                        trailing: const Icon(Icons.drag_handle, color: Colors.grey),
                        onTap: () => _showCategoryBottomSheet(category: category),
                      );
                    },
                    // 處理拖曳放開後的邏輯
                    onReorder: (oldIndex, newIndex) {
                      // Flutter ReorderableListView 的小特性：往下拖曳時 newIndex 會多 1，需要手動扣掉
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }

                      // 在本地端拷貝一份陣列並交換位置
                      final updatedList = List<CategoryEntity>.from(categories);
                      final item = updatedList.removeAt(oldIndex);
                      updatedList.insert(newIndex, item);

                      // 重新賦予所有人新的 sortOrder (就是他們在陣列裡的新 Index)
                      final newListToSave = updatedList.asMap().entries.map((entry) {
                        return entry.value.copyWith(sortOrder: entry.key);
                      }).toList();

                      // 為了讓 UI 瞬間更新不卡頓，我們先假裝已經成功了，直接把新陣列塞進畫面 (Optimistic UI Update)
                      context.read<CategoryBloc>().add(
                          ReorderCategoriesEvent(newListToSave, _isExpense ? TransactionType.expense : TransactionType.income)
                      );

                      // 背景呼叫 Bloc 把新排序存進 Firebase
                      context.read<CategoryBloc>().add(
                          ReorderCategoriesEvent(newListToSave, _isExpense ? TransactionType.expense : TransactionType.income)
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}