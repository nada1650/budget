import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/transaction_repository.dart';

class DeleteCategory implements UseCase<void, String> {
  final TransactionRepository repository;

  DeleteCategory(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.deleteCategory(params);
  }
}
