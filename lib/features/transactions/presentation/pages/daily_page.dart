import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:test_app/features/transactions/presentation/pages/add_transaction_page.dart';

import '../../../accounts/presentation/bloc/account_bloc.dart';
import '../../domain/entities/transaction_entity.dart';
import '../bloc/transaction_bloc.dart';
import 'transaction_detail_page.dart';

class DailyPage extends StatefulWidget {
  const DailyPage({super.key});

  @override
  State<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends State<DailyPage> {
  // 日曆的 UI 狀態
  CalendarFormat _calendarFormat = CalendarFormat.week; // 預設顯示單週，節省畫面空間
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // 畫面初始化時，立刻請 Bloc 抓取今天的資料
    context.read<TransactionBloc>().add(LoadTransactionsEvent(_selectedDay!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 新增資料按鈕
      floatingActionButton: FloatingActionButton(
        heroTag: 'daily_add_fab',
        onPressed: () async {
          final returnedDate = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTransactionPage(selectedDate: _selectedDay ?? DateTime.now()),
              ),
          );
          print("開始語音記帳...");

          if (returnedDate != null && context.mounted) {
            setState(() {
              _selectedDay = returnedDate;
            });
            // 重新載入當日交易紀錄
            context.read<TransactionBloc>().add(LoadTransactionsEvent(_selectedDay ?? DateTime.now()));
            _selectedDay = _selectedDay;

            // 重新載入帳戶餘額
            context.read<AccountBloc>().add(LoadAccountsEvent());
          }
        },
        child: const Icon(Icons.add, size: 32),
      ),
      body: Column(
        children: [
          // --- 日曆區塊 ---
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                // 使用者點擊新日期時，通知 Bloc 載入該日資料
                context.read<TransactionBloc>().add(LoadTransactionsEvent(selectedDay));
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const Divider(thickness: 1),

          // --- 總收支統計區塊 ---
          BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              if (state is TransactionLoaded) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('收入: \$${state.totalIncome}', style: const TextStyle(color: Colors.green)),
                      Text('支出: \$${state.totalExpense}', style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // --- 交易紀錄列表區塊 ---
          Expanded(
            child: BlocConsumer<TransactionBloc, TransactionState>(
              listener: (context, state) {
                // TransactionBloc 成功載入完資料代表背後的 Firebase 新增/刪除/修改都跑完了)
                if (state is TransactionLoaded) {
                  // 通知 AccountBloc 去抓取最新餘額
                  context.read<AccountBloc>().add(LoadAccountsEvent());
                }
              },
              builder: (context, state) {
                if (state is TransactionLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TransactionError) {
                  return Center(child: Text(state.message));
                } else if (state is TransactionLoaded) {

                  if (state.transactions.isEmpty) {
                    return const Center(child: Text('這天沒有任何記帳紀錄喔！', style: TextStyle(color: Colors.grey)));
                  }

                  return ListView.builder(
                    itemCount: state.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = state.transactions[index];
                      // 判斷是收入還是支出，決定金額顏色
                      final isExpense = transaction.type == TransactionType.expense;

                      return ListTile(
                        leading: CircleAvatar(
                          // 這裡可以換成 categoryId 對應的圖示
                          child: Icon(isExpense ? Icons.money_off : Icons.attach_money),
                        ),
                        title: Text(transaction.note.isEmpty ? '未分類' : transaction.note),
                        subtitle: Text(DateFormat('HH:mm').format(transaction.date)), // 顯示時間
                        // subtitle: Text(transaction.categoryId),
                        trailing: Text(
                          '${isExpense ? '-' : '+'}\$${transaction.amount}',
                          style: TextStyle(
                            color: isExpense ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () async {
                          // 點擊跳轉至第二級介面 (詳情頁)
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransactionDetailPage(transaction: transaction),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
                return const Center(child: Text('請選擇日期'));
              },
            ),
          ),
        ],
      ),
    );
  }
}