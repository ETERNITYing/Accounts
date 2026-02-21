import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/category_entity.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.iconCode,
    required super.colorValue,
    required super.type,
    required super.userId,
    required super.sortOrder
  });

  // 1. 將 Entity 轉成 Model
  factory CategoryModel.fromEntity(CategoryEntity categoryEntity_) {
    return CategoryModel(
      id: categoryEntity_.id,
      name: categoryEntity_.name,
      iconCode: categoryEntity_.iconCode,
      colorValue: categoryEntity_.colorValue,
      type: categoryEntity_.type,
      userId: categoryEntity_.userId,
      sortOrder: categoryEntity_.sortOrder,
    );
  }

  // 2. 從 Firebase 讀取轉換
  factory CategoryModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return CategoryModel(
      id: snap.id,
      name: data['name'] ?? '',
      iconCode: data['iconCode'] ?? 'category',
      colorValue: data['colorValue'] ?? 0xFF9E9E9E, // 預設灰色
      type: TransactionType.values.firstWhere(
            (e) => e.name == data['type'],
        orElse: () => TransactionType.expense, // 預設為支出
      ),
      userId: data['userId'] ?? '',
        sortOrder: data['sortOrder'] ?? 0,
    );
  }

  // 3. 寫入 Firebase 轉換
  Map<String, dynamic> toDocument() {
    return {
      'name': name,
      'iconCode': iconCode,
      'colorValue': colorValue,
      'type': type.name, // Enum 轉字串
      'userId': userId,
      'sortOrder': sortOrder,
    };
  }
}