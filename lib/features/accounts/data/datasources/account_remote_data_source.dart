import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/account_model.dart';

abstract class AccountRemoteDataSource {
  Future<List<AccountModel>> getAccounts();
  Future<AccountModel?> getAccountById(String id);
  Future<void> createAccount(AccountModel account);
  Future<void> updateAccount(AccountModel account);
  Future<void> deleteAccount(String id);
  Future<void> updateBalance(String accountId, double amount);
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  AccountRemoteDataSourceImpl({
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
  Future<void> updateBalance(String accountId, double amount) async {
    await firestore.collection('accounts').doc(accountId).update({
      'balance': FieldValue.increment(amount),
    });
  }

  @override
  Future<void> createAccount(AccountModel account) async {
    // 建立新文件並讓 Firestore 自動產生 ID
    final docRef = firestore.collection('accounts').doc();
    final accountData = account.toDocument();
    accountData['userId'] = _uid;
    await docRef.set(accountData);
  }

  @override
  Future<void> deleteAccount(String id) async {
    await firestore.collection('accounts').doc(id).delete();
  }

  @override
  Future<AccountModel?> getAccountById(String id) async {
    final snapshot = await firestore.collection('accounts').doc(id).get();
    if (snapshot.exists) {
      final model = AccountModel.fromSnapshot(snapshot);
      if (model.userId == _uid) {
        return model;
      }
    }
    return null;
  }

  @override
  Future<List<AccountModel>> getAccounts() async {
    final snapshot = await firestore
        .collection('accounts')
        .where('userId', isEqualTo: _uid)
        .get();
    return snapshot.docs.map((doc) => AccountModel.fromSnapshot(doc)).toList();
  }

  @override
  Future<void> updateAccount(AccountModel account) async {
    final accountData = account.toDocument();
    accountData['userId'] = _uid; // 確保更新時 UID 也不會跑掉
    await firestore.collection('accounts').doc(account.id).update(accountData);
  }
}
