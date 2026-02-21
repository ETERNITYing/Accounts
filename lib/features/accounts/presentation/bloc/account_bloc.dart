import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/usecases/read/get_accounts.dart';
import '../../domain/usecases/write/create_account.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final GetAccounts getAccounts;
  final CreateAccount createAccount;

  AccountBloc({
    required this.getAccounts,
    required this.createAccount,
  }) : super(AccountInitial()) {

    // 註冊事件處理邏輯
    on<LoadAccountsEvent>(_onLoadAccounts);
    on<AddAccountEvent>(_onAddAccount);
  }

  // 處理：載入帳戶
  Future<void> _onLoadAccounts(
      LoadAccountsEvent event,
      Emitter<AccountState> emit,
      ) async {
    if (state is! AccountLoaded) {
      emit(AccountLoading());
    }
    try {
      final accounts = await getAccounts();

      // 計算總資產
      double total = 0;
      for (var acc in accounts) {
        // 如果是信用卡(負債)，可以設計成用減的，這裡先全部加總
        total += acc.balance;
      }

      emit(AccountLoaded(accounts, total));
    } catch (e) {
      emit(AccountError("無法載入帳戶: $e"));
    }
  }

  // 處理：新增帳戶
  Future<void> _onAddAccount(
      AddAccountEvent event,
      Emitter<AccountState> emit,
      ) async {
    try {
      await createAccount(event.account);
      // 新增完畢後，重新觸發載入事件，讓畫面刷新
      add(LoadAccountsEvent());
    } catch (e) {
      emit(AccountError("新增帳戶失敗: $e"));
    }
  }
}