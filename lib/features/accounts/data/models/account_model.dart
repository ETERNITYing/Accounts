import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/account_entity.dart';

class AccountModel extends AccountEntity {
  const AccountModel({
    required super.id,
    required super.name,
    required super.balance,
    required super.iconCode,
    required super.colorValue,
    required super.type,
    required super.userId,
  });

  // 將 Entity 轉成 Model
  factory AccountModel.fromEntity(AccountEntity entity) {
    return AccountModel(
      id: entity.id,
      name: entity.name,
      balance: entity.balance,
      iconCode: entity.iconCode,
      colorValue: entity.colorValue,
      type: entity.type,
      userId: entity.userId,
    );
  }

  // 從 Firebase Snapshot 轉成本地 Model
  factory AccountModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return AccountModel(
      id: snap.id, // 直接使用文件 ID
      name: data['name'] ?? '',
      balance: (data['balance'] ?? 0.0).toDouble(),
      iconCode: data['iconCode'] ?? '',
      colorValue: data['colorValue'] ?? 0xFF000000,
      // 將字串轉回 Enum
      type: AccountType.values.firstWhere(
            (e) => e.name == data['type'],
        orElse: () => AccountType.cash,
      ),
      userId: data['userId'],
    );
  }

  // 將 Model 轉成 Map 準備存入 Firebase
  Map<String, dynamic> toDocument() {
    return {
      'name': name,
      'balance': balance,
      'iconCode': iconCode,
      'colorValue': colorValue,
      'type': type.name, // 把 Enum 轉成字串存入
      'userId': userId,
    };
  }
}