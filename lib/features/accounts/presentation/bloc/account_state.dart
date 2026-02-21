part of 'account_bloc.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final List<AccountEntity> accounts;
  // 我們可以順便算一下總資產 (把所有帳戶餘額加起來)
  final double totalAssets;

  const AccountLoaded(this.accounts, this.totalAssets);

  @override
  List<Object> get props => [accounts, totalAssets];
}

class AccountError extends AccountState {
  final String message;
  const AccountError(this.message);

  @override
  List<Object> get props => [message];
}