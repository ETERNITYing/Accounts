import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test_app/features/transactions/domain/usecases/write/update_transaction.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/read/get_daily_transactions.dart';
import '../../domain/usecases/write/add_transaction.dart';
import '../../domain/usecases/write/delete_transaction.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  // 依賴注入 Use Cases
  final GetDailyTransactions getDailyTransactions;
  final AddTransaction addTransaction;
  final DeleteTransaction deleteTransaction;
  final UpdateTransaction updateTransaction;

  TransactionBloc({
    required this.getDailyTransactions,
    required this.addTransaction,
    required this.deleteTransaction,
    required this.updateTransaction,
  }) : super(TransactionInitial()) {

    // 註冊事件處理邏輯
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<AddTransactionEvent>(_onAddTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
  }

  // 計算這筆交易對帳戶餘額的「真實影響 (Delta)」
  double _calculateBalanceDelta(TransactionEntity t) {
    // 如果是支出，傳回負數 (扣錢)；如果是收入，傳回正數 (加錢)
    return t.type == TransactionType.expense ? -t.amount : t.amount;
  }

  // 處理：載入資料
  Future<void> _onLoadTransactions(
      LoadTransactionsEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(TransactionLoading()); // 1. 先轉圈圈
    try {
      // 2. 呼叫 Use Case 抓資料
      final transactions = await getDailyTransactions(event.date);

      // 3. 計算當日總收支
      double income = 0;
      double expense = 0;
      for (var t in transactions) {
        if (t.type == TransactionType.income) {
          income += t.amount;
        } else {
          expense += t.amount;
        }
      }

      // 4. 發送成功狀態
      emit(TransactionLoaded(
        transactions: transactions,
        currentDate: event.date,
        totalIncome: income,
        totalExpense: expense,
      ));
    } catch (e) {
      emit(TransactionError("無法載入交易紀錄: $e"));
    }
  }

  // 處理：新增交易
  Future<void> _onAddTransaction(
      AddTransactionEvent event,
      Emitter<TransactionState> emit,
      ) async {
    // 注意：新增時通常也需要轉圈圈，或者 UI 層自行處理 Loading
    // 為了簡單，這裡我們假設新增很快，直接執行
    try {
      await addTransaction(event.transaction);

      // 新增完，重整列表
      add(LoadTransactionsEvent(event.transaction.date));
    } catch (e) {
      emit(TransactionError("新增失敗: $e"));
    }
  }

  // 處理：刪除交易
  Future<void> _onDeleteTransaction(
      DeleteTransactionEvent event,
      Emitter<TransactionState> emit,
      ) async {
    try {
      await deleteTransaction(event.id);

      // 刪除完後，重整列表
      add(LoadTransactionsEvent(event.currentDate));
    } catch (e) {
      emit(TransactionError("刪除失敗: $e"));
    }
  }

  Future<void> _onUpdateTransaction(
      UpdateTransactionEvent event,
      Emitter<TransactionState> emit,
      ) async {
    try {
      await updateTransaction(event.transaction);

      // 更新完後，重整列表
      add(LoadTransactionsEvent(event.transaction.date));
    } catch(e) {
      emit(TransactionError("更新失敗: $e"));
    }
  }
}