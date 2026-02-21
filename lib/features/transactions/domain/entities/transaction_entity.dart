import 'package:equatable/equatable.dart';

// 定義交易類型
enum TransactionType { income, expense, transfer }

class TransactionEntity extends Equatable {
  final String id;
  final String accountId;
  final double amount;
  final DateTime date;
  final String note;
  final TransactionType type;
  final String categoryId;
  final String userId;

  const TransactionEntity({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.date,
    required this.note,
    required this.type,
    required this.categoryId,
    required this.userId,
  });

  @override
  List<Object?> get props => [id, amount, date, note, type, categoryId, userId];
}