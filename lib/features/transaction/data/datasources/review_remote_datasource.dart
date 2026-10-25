import 'package:neu_trade/core/error/exceptions.dart';
import 'package:neu_trade/core/services/review_services.dart';
import 'package:neu_trade/features/transaction/data/models/review_model.dart';
import 'package:supabase/supabase.dart';

abstract class ReviewRemoteDatasource {
  Future<ReviewModel> submitReview({
    required int transactionId,
    required int stars,
    String? content,
  });
}

class ReviewRemoteDatasourceImpl implements ReviewRemoteDatasource {
  final ReviewServices _reviewServices;

  const ReviewRemoteDatasourceImpl(this._reviewServices);

  @override
  Future<ReviewModel> submitReview({
    required int transactionId,
    required int stars,
    String? content,
  }) async {
    try {
      final result = await _reviewServices.createReview(
        transactionId: transactionId,
        stars: stars,
        content: content,
      );
      return ReviewModel.fromJson(result);
    } on PostgrestException catch (error) {
      throw ServerException(message: error.message);
    }
  }
}
