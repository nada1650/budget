import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/transactions/data/datasources/transaction_local_data_source.dart';
import 'features/transactions/data/models/category_model.dart';
import 'features/transactions/data/models/transaction_model.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';
import 'features/transactions/domain/usecases/add_transaction.dart';
import 'features/transactions/domain/usecases/get_categories.dart';
import 'features/transactions/domain/usecases/get_transactions.dart';
import 'features/transactions/domain/usecases/add_category.dart';
import 'features/transactions/domain/usecases/delete_category.dart';
import 'features/transactions/domain/usecases/sync_data.dart';
import 'features/transactions/presentation/cubit/transactions_cubit.dart';
import 'features/settings/presentation/cubit/theme_cubit.dart';
import 'core/services/biometric_service.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/transactions/data/datasources/transaction_remote_data_source.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Cubit
  sl.registerFactory(() => TransactionsCubit(
        getTransactions: sl(),
        addTransaction: sl(),
        getCategories: sl(),
        addCategoryUseCase: sl(),
        deleteCategoryUseCase: sl(),
        syncDataUseCase: sl(),
      ));
  sl.registerFactory(() => ThemeCubit());
  sl.registerFactory(() => AuthCubit(sl()));

  // UseCases
  sl.registerLazySingleton(() => GetTransactions(sl()));
  sl.registerLazySingleton(() => AddTransaction(sl()));
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => AddCategory(sl()));
  sl.registerLazySingleton(() => DeleteCategory(sl()));
  sl.registerLazySingleton(() => SyncData(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<TransactionLocalDataSource>(
    () => TransactionLocalDataSourceImpl(
      transactionBox: sl(),
      categoryBox: sl(),
    ),
  );

  // External (Hive)
  await Hive.initFlutter();
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(TransactionTypeModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());

  final transactionBox = await Hive.openBox<TransactionModel>('transactions');
  final categoryBox = await Hive.openBox<CategoryModel>('categories');
  final settingsBox = await Hive.openBox('settings');

  sl.registerLazySingleton(() => transactionBox);
  sl.registerLazySingleton(() => categoryBox);
  sl.registerLazySingleton<Box>(() => settingsBox, instanceName: 'settingsBox');
  sl.registerLazySingleton(() => BiometricService());
}
