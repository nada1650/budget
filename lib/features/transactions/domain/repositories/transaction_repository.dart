import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../entities/category.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<TransactionEntity>>> getTransactions();
  Future<Either<Failure, void>> syncData(String userId);
  Future<Either<Failure, void>> addTransaction(TransactionEntity transaction);
  Future<Either<Failure, void>> deleteTransaction(String id);
  Future<Either<Failure, List<TransactionCategory>>> getCategories();
  Future<Either<Failure, void>> addCategory(TransactionCategory category);
  Future<Either<Failure, void>> deleteCategory(String id);
}
