import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<void> addTransaction(TransactionModel transactionModel_);
  Future<void> deleteTransaction(String id);
  Future<void> updateTransaction(TransactionModel transactionModel_);
  Future<List<TransactionModel>> getDailyTransactions(DateTime date);
  Future<List<TransactionModel>> getTransactionsByDate(DateTime start, DateTime end);
  Future<TransactionModel?> getTransactionById(String id);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  TransactionRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  // 獲取當前使用者的 UID
  String get _uid {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User is not logged in! 無法存取資料庫。');
    }
    return user.uid;
  }

  @override
  Future<void> addTransaction(TransactionModel transactionModel_) async {
    // 使用 Model 的 toDocument() 方法轉成 Map
    final data = transactionModel_.toDocument();
    data['userId'] = _uid;
    await firestore.collection('transactions').add(data);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await firestore.collection('transactions').doc(id).delete();
  }

  @override
  Future<void> updateTransaction(TransactionModel transactionModel_) async {
    try {
      // 根據 Document ID 找到同一筆資料並更新
      final data = transactionModel_.toDocument();
      data['userId'] = _uid; // 確保更新時 UID 也不會跑掉

      await firestore.collection('transactions').doc(transactionModel_.id).update(data);
    } catch(e) {
      throw Exception('Error updating transaction: $e');
    }
  }

  @override
  Future<List<TransactionModel>> getDailyTransactions(DateTime date) async {
    //今日時間區間
    final tStartOfDay = DateTime(date.year, date.month, date.day);
    final tNextOfDay = tStartOfDay.add(const Duration(days: 1));

    try {
      final snapshot = await firestore
          .collection('transactions')
          .where('userId', isEqualTo: _uid)
          .where('date', isGreaterThanOrEqualTo: tStartOfDay)
          .where('date', isLessThan: tNextOfDay)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) => TransactionModel.fromSnapshot(doc)).toList();
    } catch(e) {
      throw Exception('Error fetching transactions: $e');
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionsByDate(DateTime startOfDay, DateTime endOfDay) async {
    //今日時間區間
    final tStartOfDay = DateTime(startOfDay.year, startOfDay.month, startOfDay.day);
    final tEndOfDay = DateTime(endOfDay.year, endOfDay.month, endOfDay.day);

    try {
      final snapshot = await firestore
          .collection('transactions')
          .where('userId', isEqualTo: _uid)
          .where('date', isGreaterThanOrEqualTo: tStartOfDay)
          .where('date', isLessThan: tEndOfDay)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) => TransactionModel.fromSnapshot(doc)).toList();
    } catch(e) {
      throw Exception('Error fetching transactions: $e');
    }
  }

  @override
  Future<TransactionModel?> getTransactionById(String id) async {
    try {
      final snapshot = await firestore
          .collection('transactions')
          .doc(id)
          .get();

      if (snapshot.exists) {
        final model = TransactionModel.fromSnapshot(snapshot);
        if (model.userId == _uid) {
          return model;
        }
      }
      return null;
    } catch(e) {
      throw Exception('Error fetching transactions: $e');
    }
  }
}