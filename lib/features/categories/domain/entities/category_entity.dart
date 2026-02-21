import 'package:equatable/equatable.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;      // 分類名稱
  final String iconCode;  // 圖示代碼
  final int colorValue;   // 顏色代碼
  final TransactionType type; // 收入支出
  final String userId;    // 安全隔離用

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    required this.type,
    required this.userId,
  });

  @override
  List<Object?> get props => [id, name, iconCode, colorValue, type, userId];
}