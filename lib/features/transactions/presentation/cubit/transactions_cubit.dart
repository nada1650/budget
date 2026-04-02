import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/add_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/entities/category.dart';
import 'transactions_state.dart';

import '../../domain/usecases/sync_data.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  final GetTransactions getTransactions;
  final AddTransaction addTransaction;
  final GetCategories getCategories;
  final AddCategory addCategoryUseCase;
  final DeleteCategory deleteCategoryUseCase;
  final SyncData syncDataUseCase;

  TransactionsCubit({
    required this.getTransactions,
    required this.addTransaction,
    required this.getCategories,
    required this.addCategoryUseCase,
    required this.deleteCategoryUseCase,
    required this.syncDataUseCase,
  }) : super(TransactionsInitial());

  void loadData() async {
    emit(TransactionsLoading());

    final categoriesEither = await getCategories(NoParams());
    final transactionsEither = await getTransactions(NoParams());

    categoriesEither.fold(
      (failure) => emit(TransactionsError(message: failure.message)),
      (categories) {
        transactionsEither.fold(
          (failure) => emit(TransactionsError(message: failure.message)),
          (transactions) => emit(TransactionsLoaded(
            transactions: transactions,
            categories: categories,
          )),
        );
      },
    );
  }

  void addNewTransaction(TransactionEntity transaction) async {
    final currentState = state;
    if (currentState is TransactionsLoaded) {
      final result = await addTransaction(transaction);
      result.fold(
        (failure) => emit(TransactionsError(message: failure.message)),
        (_) {
          // Reload all transactions after success
          loadData();
        },
      );
    }
  }

  void addNewCategory(TransactionCategory category) async {
    final currentState = state;
    if (currentState is TransactionsLoaded) {
      final result = await addCategoryUseCase(category);
      result.fold(
        (failure) => emit(TransactionsError(message: failure.message)),
        (_) {
          loadData();
        },
      );
    }
  }

  void removeCategory(String id) async {
    final currentState = state;
    if (currentState is TransactionsLoaded) {
      final result = await deleteCategoryUseCase(id);
      result.fold(
        (failure) => emit(TransactionsError(message: failure.message)),
        (_) {
          loadData();
        },
      );
    }
  }

  Future<void> syncDataToCloud(String userId) async {
    emit(TransactionsLoading());
    final result = await syncDataUseCase(userId);
    result.fold(
      (failure) => emit(TransactionsError(message: failure.message)),
      (_) => loadData(),
    );
  }
}

