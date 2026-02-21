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
  });

  // 1. 將 Entity 轉成 Model
  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      iconCode: entity.iconCode,
      colorValue: entity.colorValue,
      type: entity.type,
      userId: entity.userId,
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
    };
  }
}