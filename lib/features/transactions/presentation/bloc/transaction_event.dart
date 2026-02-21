part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

// 1. 載入某日期的交易
class LoadTransactionsEvent extends TransactionEvent {
  final DateTime date;

  const LoadTransactionsEvent(this.date);

  @override
  List<Object> get props => [date];
}

// 2. 新增交易
class AddTransactionEvent extends TransactionEvent {
  final TransactionEntity transaction;

  const AddTransactionEvent(this.transaction);

  @override
  List<Object> get props => [transaction];
}

// 3. 刪除交易
class DeleteTransactionEvent extends TransactionEvent {
  final String id;
  // 重整列表，紀錄時間
  final DateTime currentDate;

  const DeleteTransactionEvent(this.id, this.currentDate);

  @override
  List<Object> get props => [id, currentDate];
}

// 4. 更新交易
class UpdateTransactionEvent extends TransactionEvent {
  final TransactionEntity transaction;
  const UpdateTransactionEvent(this.transaction);
}