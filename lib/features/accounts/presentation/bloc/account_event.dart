part of 'account_bloc.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object> get props => [];
}

class LoadAccountsEvent extends AccountEvent {}

class AddAccountEvent extends AccountEvent {
  final AccountEntity account;
  const AddAccountEvent(this.account);

  @override
  List<Object> get props => [account];
}