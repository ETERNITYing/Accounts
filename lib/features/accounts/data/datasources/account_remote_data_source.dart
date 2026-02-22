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
    try {
      // 直接執行更新
      await firestore.collection('accounts').doc(accountId).update({
        'balance': FieldValue.increment(amount),
      });

    } on FirebaseException catch (e) {
      // 攔截「找不到文件 (not-found)」
      // 以及「因為文件不存在導致安全規則崩潰 (permission-denied)」的錯誤
      if (e.code == 'not-found' || e.code == 'permission-denied') {
        print('帳戶 $accountId 不存在或已被刪除，跳過餘額更新');
        return; // 默默結束，不拋出錯誤，讓外層的更新邏輯可以順利跑完
      }

      // 其他嚴重錯誤才真的丟出去
      throw Exception('Update balance failed: ${e.message}');
    } catch (e) {
      throw Exception('Update balance failed: $e');
    }
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
