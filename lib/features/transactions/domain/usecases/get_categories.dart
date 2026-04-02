import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category.dart';
import '../repositories/transaction_repository.dart';

class GetCategories implements UseCase<List<TransactionCategory>, NoParams> {
  final TransactionRepository repository;

  GetCategories(this.repository);

  @override
  Future<Either<Failure, List<TransactionCategory>>> call(NoParams params) async {
    return await repository.getCategories();
  }
}
