import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/transaction_entity.dart';
import '../bloc/transaction_bloc.dart';
import '../../../accounts/presentation/bloc/account_bloc.dart';
import '../../../categories/presentation/bloc/category_bloc.dart';

class TransactionDetailPage extends StatefulWidget {
  final TransactionEntity transaction; // 接收點擊進來的舊資料

  const TransactionDetailPage({super.key, required this.transaction});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late bool _isExpense;
  String? _selectedAccountId;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // 畫面載入時，直接把舊資料填進去！
    _amountController = TextEditingController(text: widget.transaction.amount.toStringAsFixed(0));
    _noteController = TextEditingController(text: widget.transaction.note);
    _isExpense = widget.transaction.type == TransactionType.expense;
    _selectedCategoryId = widget.transaction.categoryId;
    _selectedAccountId = widget.transaction.accountId;

    context.read<CategoryBloc>().add(LoadCategoriesEvent(
      _isExpense ? TransactionType.expense : TransactionType.income,
    ));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // 儲存修改
  void _updateTransaction() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    final updatedRecord = TransactionEntity(
      id: widget.transaction.id, // 沿用原本的 ID
      amount: amount,
      note: _noteController.text,
      date: widget.transaction.date, // 沿用原本的時間
      type: _isExpense ? TransactionType.expense : TransactionType.income,
      categoryId: _selectedCategoryId!,
      accountId: _selectedAccountId!,
      userId: '',
    );

    // 發送更新事件
    context.read<TransactionBloc>().add(UpdateTransactionEvent(updatedRecord));
    Navigator.pop(context); // 回到上一頁
  }

  // 刪除確認對話框
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除紀錄'),
        content: const Text('確定要刪除這筆記帳紀錄嗎？此動作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // 取消
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // 發送刪除事件
              context.read<TransactionBloc>().add(
                  DeleteTransactionEvent(
                    widget.transaction.id,
                    widget.transaction.date,
                  )
              );
              Navigator.pop(context); // 關閉對話框
              Navigator.pop(context); // 回到列表頁
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('編輯紀錄'),
        actions: [
          // 右上角的垃圾桶刪除按鈕
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 收支切換開關
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('支出')),
                ButtonSegment(value: false, label: Text('收入')),
              ],
              selected: {_isExpense},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _isExpense = newSelection.first;
                  _selectedCategoryId = null;
                });
                // 重新載入分類
                context.read<CategoryBloc>().add(LoadCategoriesEvent(
                  _isExpense ? TransactionType.expense : TransactionType.income,
                ));
              },
            ),
            const SizedBox(height: 16),

            // 金額輸入
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '金額',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder()
              ),
            ),
            const SizedBox(height: 16),

            // 帳戶下拉選單
            BlocBuilder<AccountBloc, AccountState>(
              builder: (context, state) {
                if (state is AccountLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AccountLoaded) {
                  final accounts = state.accounts;

                  // 防呆：如果還沒有建立任何帳戶
                  if (accounts.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('請先至「review」建立至少一個帳戶才能記帳', style: TextStyle(color: Colors.red)),
                    );
                  }

                  // 如果還沒選擇，或者選中的 ID 已經不在列表中，預設選擇第一個帳戶
                  if (_selectedAccountId == null || !accounts.any((a) => a.id == _selectedAccountId)) {
                    // 使用延遲來避免在 build 過程中直接呼叫 setState
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _selectedAccountId = accounts.first.id);
                    });
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedAccountId,
                    decoration: const InputDecoration(
                      labelText: '扣款 / 入帳帳戶',
                      prefixIcon: Icon(Icons.account_balance_wallet),
                      border: OutlineInputBorder(),
                    ),
                    items: accounts.map((account) {
                      return DropdownMenuItem(
                        value: account.id,
                        child: Text(account.name), // 顯示帳戶名稱
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedAccountId = newValue;
                      });
                    },
                  );
                }
                return const SizedBox.shrink(); // Error 狀態先簡單隱藏
              },
            ),
            const SizedBox(height: 16),

            // 備註輸入
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                  labelText: '備註項目',
                  prefixIcon: Icon(Icons.edit_note),
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // --- 分類選擇區塊 (UI Placeholder) ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('選擇分類', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            const SizedBox(height: 8),
            BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CategoryLoaded) {
                  final categories = state.categories;

                  if (categories.isEmpty) {
                    return const Text('沒有可用的分類', style: TextStyle(color: Colors.grey));
                  }
                  // 如果還沒選擇分類，預設自動選第一個
                  if (_selectedCategoryId == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _selectedCategoryId = categories.first.id);
                    });
                  }
                  return Wrap(
                    spacing: 8.0, // 標籤之間的水平間距
                    runSpacing: 8.0, // 換行後的垂直間距
                    children: categories.map((category) {
                      return ChoiceChip(
                        label: Text(category.name),
                        selected: _selectedCategoryId == category.id,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) _selectedCategoryId = category.id;
                          });
                        },
                        selectedColor: Color(category.colorValue).withOpacity(0.3),
                        // selectedColor: Theme.of(context).colorScheme.primaryContainer,
                        checkmarkColor: Theme.of(context).colorScheme.primary,
                      );
                    }).toList(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const Spacer(),

            // 儲存修改按鈕
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _updateTransaction,
                child: const Text('儲存修改', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}