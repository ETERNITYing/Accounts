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

class UpdateAccountEvent extends AccountEvent {
  final AccountEntity account;
  const UpdateAccountEvent(this.account);

  @override
  List<Object> get props => [account];
}

class DeleteAccountEvent extends AccountEvent {
  final String accountId;
  const DeleteAccountEvent(this.accountId);

  @override
  List<Object> get props => [accountId];
}