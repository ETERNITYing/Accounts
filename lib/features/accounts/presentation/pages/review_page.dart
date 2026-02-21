import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/account_entity.dart';
import '../bloc/account_bloc.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  @override
  void initState() {
    super.initState();
    // 切換到總覽頁面時，通知 Bloc 抓取最新帳戶與餘額資料
    context.read<AccountBloc>().add(LoadAccountsEvent());
  }

  // 顯示新增帳戶的底部彈出視窗
  void _showAddAccountBottomSheet() {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    AccountType selectedType = AccountType.cash;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 24, right: 24, top: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('新增帳戶', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: '帳戶名稱', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: balanceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '目前餘額', border: OutlineInputBorder(), prefixIcon: Icon(Icons.attach_money)),
                    ),
                    const SizedBox(height: 16),
                    const Text('帳戶類型', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<AccountType>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(value: AccountType.cash, label: Text('現金')),
                          ButtonSegment(value: AccountType.bank, label: Text('銀行')),
                          ButtonSegment(value: AccountType.creditCard, label: Text('信用卡')),
                        ],
                        selected: {selectedType},
                        onSelectionChanged: (Set<AccountType> newSelection) {
                          setModalState(() => selectedType = newSelection.first);
                        },
                      ),
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          final balance = double.tryParse(balanceController.text) ?? 0.0;
                          if (name.isEmpty) return;

                          final newAccount = AccountEntity(
                            id: '',
                            name: name,
                            balance: balance,
                            iconCode: 'account_balance_wallet',
                            colorValue: 0xFF4CAF50,
                            type: selectedType,
                            userId: '',
                          );

                          context.read<AccountBloc>().add(AddAccountEvent(newAccount));
                          Navigator.pop(context);
                        },
                        child: const Text('儲存帳戶', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('資產總覽'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'review_add_fab',
        onPressed: _showAddAccountBottomSheet,
        child: const Icon(Icons.add_card),
      ),
      body: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (state is AccountLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AccountError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          } else if (state is AccountLoaded) {
            final accounts = state.accounts;

            return Column(
              children: [
                // --- 頂部：總資產看板 ---
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    // 讓總覽卡片使用主題色，看起來更大氣
                      gradient: LinearGradient(
                        colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.tertiary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                      ]
                  ),
                  child: Column(
                    children: [
                      const Text('總資產淨值', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                          '\$${state.totalAssets.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                ),

                // --- 列表標題 ---
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('我的帳戶', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                ),

                // --- 列表：各個帳戶 ---
                Expanded(
                  child: accounts.isEmpty
                      ? const Center(child: Text('尚未建立任何帳戶，點擊右下角新增吧！', style: TextStyle(color: Colors.grey)))
                      : ListView.separated(
                    itemCount: accounts.length,
                    separatorBuilder: (_, __) => const Divider(indent: 70, endIndent: 20, height: 1),
                    itemBuilder: (context, index) {
                      final account = accounts[index];

                      IconData accountIcon = Icons.account_balance_wallet;
                      if (account.type == AccountType.bank) accountIcon = Icons.account_balance;
                      if (account.type == AccountType.creditCard) accountIcon = Icons.credit_card;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                          child: Icon(accountIcon, color: Theme.of(context).colorScheme.onSecondaryContainer),
                        ),
                        title: Text(account.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text(account.type.name.toUpperCase()),
                        trailing: Text(
                          '\$${account.balance.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}