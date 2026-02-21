import 'package:equatable/equatable.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;      // 分類名稱
  final String iconCode;  // 圖示代碼
  final int colorValue;   // 顏色代碼
  final TransactionType type; // 收入支出
  final String userId;    // 安全隔離用
  final int sortOrder;     // 排序順序

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    required this.type,
    required this.userId,
    required this.sortOrder,
  });

  CategoryEntity copyWith({
    String? id, String? name, String? iconCode, int? colorValue,
    TransactionType? type, String? userId, int? sortOrder,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [id, name, iconCode, colorValue, type, userId, sortOrder];
}