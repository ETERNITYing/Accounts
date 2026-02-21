import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.accountId,
    required super.amount,
    required super.date,
    required super.note,
    required super.type,
    required super.categoryId,
    required super.userId,
  });

  factory TransactionModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      accountId: data['accountId'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      note: data['note'] ?? '',
      type: TransactionType.values.firstWhere(
            (e) => e.name == data['type'],
            orElse: () => TransactionType.expense,
      ),
      categoryId: data['categoryId'],
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'accountId': accountId,
      'amount': amount,
      'date': Timestamp.fromDate(date), // DateTime 轉 Timestamp
      'note': note,
      'type': type.name, // Enum 轉字串存
      'categoryId': categoryId,
      'userId': userId,
    };
  }
}