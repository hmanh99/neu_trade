import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/exceptions.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/features/transaction/data/datasources/review_remote_datasource.dart';
import 'package:neu_trade/features/transaction/domain/entities/review_entity.dart';
import 'package:neu_trade/features/transaction/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDatasource remoteDatasource;

  ReviewRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, ReviewEntity>> submitReview({
    required int transactionId,
    required int stars,
    String? content,
  }) async {
    try {
      final result = await remoteDatasource.submitReview(
        transactionId: transactionId,
        stars: stars,
        content: content,
      );
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
