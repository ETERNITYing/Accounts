part of 'transaction_bloc.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

// 成功載入資料
class TransactionLoaded extends TransactionState {
  final List<TransactionEntity> transactions;
  final DateTime currentDate; // 記住現在顯示的是哪一天的資料
  final double totalIncome;   // 直接在 Bloc 算好總收入給 UI
  final double totalExpense;  // 直接在 Bloc 算好總支出給 UI

  const TransactionLoaded({
    required this.transactions,
    required this.currentDate,
    this.totalIncome = 0,
    this.totalExpense = 0,
  });

  @override
  List<Object> get props => [transactions, currentDate, totalIncome, totalExpense];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object> get props => [message];
}