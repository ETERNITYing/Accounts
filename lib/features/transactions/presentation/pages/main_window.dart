import 'package:flutter/material.dart';
// DI
import '../../../accounts/presentation/pages/review_page.dart';
import 'daily_page.dart';
import '../../../settings/presentation/pages/main_setting_page.dart';

class MainWindow extends StatefulWidget
{
  const MainWindow({super.key});

  @override
  State<MainWindow> createState() => _MainWindowState();
}

class _MainWindowState extends State<MainWindow>
{
  int _selectedIndex = 1; //預選中間頁面

  // 3. 定義頁面列表 (按照 NavigationBar 的順序排列)
  final List<Widget> _pages = [
    const ReviewPage(),  // Index 0
    const DailyPage(),  // Index 1
    const MainSettingPage(), // Index 2
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Keep Accounts')
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(

        selectedIndex: _selectedIndex,

        onDestinationSelected:(int index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        destinations: <Widget>[
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined, color: Colors.grey), // 未選中圖示
            selectedIcon: const Icon(Icons.calendar_month, color: Colors.black38), // 選中時圖示 (實心/白色)
            label: 'Review',
          ),

          const NavigationDestination(
            icon: Icon(Icons.add_box_outlined, color: Colors.grey), // 未選中圖示
            selectedIcon: Icon(Icons.add_box, color: Colors.black38), // 選中時圖示 (實心/白色)
            label: 'Daily',
          ),

          const NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: Colors.grey), // 未選中圖示
            selectedIcon: Icon(Icons.settings, color: Colors.black38), // 選中時圖示 (實心/白色)
            label: 'Setting',
          ),
        ],
      ),
    );
  }
}