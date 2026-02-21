import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:test_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:test_app/features/categories/presentation/bloc/category_bloc.dart';
import 'package:test_app/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/transactions/presentation/pages/main_window.dart';
import 'theme_data.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Firebase (請確保已設定 firebase_options.dart)
  await Firebase.initializeApp();

  // 初始化依賴注入
  await di.init();

  // try {
  //   final userCredential = await FirebaseAuth.instance.signInAnonymously();
  //   print('登入成功！當前使用者的 UID 是: ${userCredential.user?.uid}');
  // } catch (e) {
  //   print('匿名登入失敗: $e');
  // }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return  MultiBlocProvider(
          providers: [
            BlocProvider<TransactionBloc>(
              create: (_) => di.sl<TransactionBloc>(),
            ),
            BlocProvider<AccountBloc>(
              create: (_) => di.sl<AccountBloc>(),
            ),
            BlocProvider<CategoryBloc>(
              create: (_) => di.sl<CategoryBloc>()..add(InitializeDefaultCategoriesEvent()),
            ),
            BlocProvider<AuthBloc>(
              create: (_) => di.sl<AuthBloc>()..add(AppStartedEvent()),
            ),
          ],
            child: MaterialApp(
            title: 'Clean Architecture Demo',
            theme: buildTheme(lightDynamic, false),
            darkTheme: buildTheme(darkDynamic, true),
            themeMode: ThemeMode.system,
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                // 如果已經登入，就進入主程式
                if (state is Authenticated) {
                  return const MainWindow();
                }
                // 其他狀態 (包含未登入、初始狀態)，一律顯示登入頁
                return const LoginPage();
              },
            ),// 進入第一級介面
          )
        );
      }
    );
  }
}