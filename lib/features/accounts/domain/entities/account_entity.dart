import 'package:equatable/equatable.dart';

// domain/entities/account_entity.dart

enum AccountType {
  cash,       // 現金 (資產)
  bank,       // 銀行 (資產)
  creditCard, // 信用卡 (負債)
}

class AccountEntity extends Equatable {
  final String id;
  final String name;      // 帳戶名稱
  final double balance;   // 目前餘額
  final String iconCode;  // 圖示代碼
  final int colorValue;   // 顏色代碼
  final AccountType type;
  final String userId;

  const AccountEntity({
    required this.id,
    required this.name,
    required this.balance,
    required this.iconCode,
    required this.colorValue,
    required this.type,
    required this.userId,
  });

  AccountEntity copyWith({
    String? id,
    String? name,
    double? balance,
    String? iconCode,
    int? colorValue,
    AccountType? type,
    String? userId,
  }) {
    return AccountEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      type:  type ?? this.type,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [id, name, balance, iconCode, colorValue, type, userId];
}