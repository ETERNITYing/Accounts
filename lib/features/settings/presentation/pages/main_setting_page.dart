// 檔案：lib/features/settings/presentation/pages/setting_main_page.dart
import 'package:flutter/material.dart';
import '../../../categories/presentation/pages/category_manage_page.dart';
import 'ai_setting_page.dart'; // 引入剛剛改名好的 AI 設定頁面

class MainSettingPage extends StatelessWidget {
  const MainSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 使用 ListView 讓未來選單變多時可以滑動
      body: ListView(
        children: [
          // 第一個區塊：進階功能
          const _SectionHeader(title: '進階功能'),
          ListTile(
            leading: const Icon(Icons.smart_toy_outlined, color: Colors.blueAccent),
            title: const Text('AI 語音助理'),
            subtitle: const Text('管理 Gemini API 金鑰與語音偏好'),
            trailing: const Icon(Icons.chevron_right), // 右側的小箭頭，暗示可以點進去
            onTap: () {
              // 點擊後推入 (Push) AI 設定子頁面
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AiSettingPage()),
              );
            },
          ),

          const Divider(),

          // 第二個區塊：資料管理 (預留區塊)
          const _SectionHeader(title: '資料管理'),
          // ListTile(
          //   leading: const Icon(Icons.account_balance_wallet_outlined),
          //   title: const Text('帳戶與餘額'),
          //   trailing: const Icon(Icons.chevron_right),
          //   onTap: () {
          //     // TODO: 未來實作帳戶管理頁面
          //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('即將推出')));
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('收支分類'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoryManagePage()),
              );
            },
          ),

          const Divider(),

          // 第三個區塊：關於應用程式 (預留區塊)
          const _SectionHeader(title: '其他'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('關於 Keep Accounts'),
            onTap: () {
              // TODO: 顯示版本號等資訊
            },
          ),
        ],
      ),
    );
  }
}

// 自訂的私有小元件，用來畫出灰色的分類標題
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}