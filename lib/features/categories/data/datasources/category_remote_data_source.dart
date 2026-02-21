import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/category_model.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories(TransactionType type);
  Future<void> createCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  CategoryRemoteDataSourceImpl({
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
  Future<List<CategoryModel>> getCategories(TransactionType type) async {
    final snapshot = await firestore
        .collection('categories')
        .where('userId', isEqualTo: _uid)
        .where('type', isEqualTo: type.name) // 過濾是收入還是支出的分類
        .get();

    return snapshot.docs.map((doc) => CategoryModel.fromSnapshot(doc)).toList();
  }

  @override
  Future<void> createCategory(CategoryModel category) async {
    final data = category.toDocument();
    data['userId'] = _uid; // 強制綁定 UID

    // 如果 category.id 是空的，讓 Firestore 自動產生 ID；否則使用指定的 ID
    if (category.id.isEmpty) {
      await firestore.collection('categories').add(data);
    } else {
      await firestore.collection('categories').doc(category.id).set(data);
    }
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    final data = category.toDocument();
    data['userId'] = _uid;// 確保更新時 UID 也不會跑掉
    await firestore.collection('categories').doc(category.id).update(data);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await firestore.collection('categories').doc(id).delete();
  }
}