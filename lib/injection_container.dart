import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_app/features/accounts/domain/usecases/write/delete_account.dart';
import 'package:test_app/features/accounts/domain/usecases/write/update_account.dart';
import 'package:test_app/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:test_app/features/transactions/domain/usecases/write/update_transaction.dart';

// Import all features (Blocs, UseCases, Repos, DataSources)
// transaction Bloc and use case
import 'features/transactions/presentation/bloc/transaction_bloc.dart';
import 'features/transactions/domain/usecases/write/add_transaction.dart';
import 'features/transactions/domain/usecases/write/delete_transaction.dart';
import 'features/transactions/domain/usecases/read/get_daily_transactions.dart';
// transaction repo and data
import 'features/transactions/domain/repositories/transaction_repository.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/data/datasources/transaction_remote_data_source.dart';
// account Bloc and use case
import 'features/accounts/presentation/bloc/account_bloc.dart';
import 'features/accounts/domain/usecases/write/create_account.dart';
import 'features/accounts/domain/usecases/write/update_account.dart';
import 'features/accounts/domain/usecases/write/delete_account.dart';
import 'features/accounts/domain/usecases/read/get_accounts.dart';
// account repo and data
import 'features/accounts/domain/repositories/account_repository.dart';
import 'features/accounts/data/repositories/account_repository_impl.dart';
import 'features/accounts/data/datasources/account_remote_data_source.dart';
// category Bloc and use case
import 'features/categories/presentation/bloc/category_bloc.dart';
import 'features/categories/domain/usecases/init_default_categories.dart';
import 'features/categories/domain/usecases/update_category_orders.dart';
import 'features/categories/domain/usecases/write/create_category.dart';
import 'features/categories/domain/usecases/write/update_category.dart';
import 'features/categories/domain/usecases/write/delete_category.dart';
import 'features/categories/domain/usecases/read/get_categories.dart';
// category repo and data
import 'features/categories/domain/repositories/category_repository.dart';
import 'features/categories/data/repositories/category_repository_impl.dart';
import 'features/categories/data/datasources/category_remote_data_source.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  //  Features - Transaction
  //  Bloc
  sl.registerFactory(
    () => TransactionBloc(
      addTransaction: sl(), // 自動注入 AddTransactionRecord
      deleteTransaction: sl(), // 自動注入 DeleteTransactionRecord
      getDailyTransactions: sl(), // 自動注入 GetDailyTransactions
      updateTransaction: sl(), // 自動注入 UpdateTransaction
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => AddTransaction(
        sl(), // 注入 TransactionRecordRepository
        sl(), // 注入 AccountRepository
      ));

  sl.registerLazySingleton(() => DeleteTransaction(
        sl(), // 注入 TransactionRecordRepository
        sl(), // 注入 AccountRepository
      ));

  sl.registerLazySingleton(() => UpdateTransaction(
        sl(), // 注入 TransactionRecordRepository
        sl(), // 注入 AccountRepository
      ));

  sl.registerLazySingleton(() => GetDailyTransactions(sl()));

  // Repository
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(firestore: sl(), firebaseAuth: sl()),
  );

  // Features - Account
  // Bloc
  sl.registerFactory(() => AccountBloc(
        getAccounts: sl(),
        createAccount: sl(),
        updateAccount: sl(),
        deleteAccount: sl(),
      ),
  );
  // Use Cases
  sl.registerLazySingleton(() => GetAccounts(sl()));

  sl.registerLazySingleton(() => CreateAccount(sl()));

  sl.registerLazySingleton(() => UpdateAccount(sl()));

  sl.registerLazySingleton(() => DeleteAccount(sl()));
  // Repository
  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<AccountRemoteDataSource>(
    () => AccountRemoteDataSourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
    ),
  );

  // Features - Category
  // Bloc
  sl.registerFactory(() => CategoryBloc(
      initDefaultCategories: sl(),
      getCategories: sl(),
      createCategory: sl(),
      updateCategory: sl(),
      deleteCategory: sl(),
      updateCategoryOrders: sl(),
    )
  );
  // Use cases
  sl.registerLazySingleton(() => InitDefaultCategories(sl()));

  sl.registerLazySingleton(() => UpdateCategoryOrders(sl()));

  sl.registerLazySingleton(() => GetCategories(sl()));

  sl.registerLazySingleton(() => CreateCategory(sl()));

  sl.registerLazySingleton(() => UpdateCategory(sl()));

  sl.registerLazySingleton(() => DeleteCategory(sl()));
  // Repository
  sl.registerLazySingleton<CategoryRepository>(
        () => CategoryRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<CategoryRemoteDataSource>(
        () => CategoryRemoteDataSourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
    ),
  );

  // External (外部依賴)
  // Firestore 實體
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  // Firebase Auth
  sl.registerLazySingleton(() => FirebaseAuth.instance);
}
