import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/features/review/data/models/review_model.dart';
import 'package:neu_trade/features/review/domain/entities/rating_summary_entity.dart';
import 'package:neu_trade/features/review/domain/entities/review_entity.dart';
import 'package:neu_trade/features/review/domain/repositories/review_repository.dart';
import 'package:neu_trade/features/review/domain/usecases/submit_review_usecase.dart';

class MockReviewRepository implements ReviewRepository {
  bool submitReviewCalled = false;

  @override
  Future<Either<Failure, ReviewEntity>> submitReview({
    required int transactionId,
    required int stars,
    String? content,
  }) async {
    submitReviewCalled = true;
    return Right(
      ReviewEntity(
        reviewId: 1,
        transactionId: transactionId,
        reviewerId: 'buyer-uuid',
        targetUserId: 'seller-uuid',
        stars: stars,
        content: content,
        createdAt: DateTime(2026, 10, 17),
      ),
    );
  }

  @override
  Future<Either<Failure, RatingSummaryEntity>> getRatingSummary({
    required String targetUserId,
  }) async {
    return const Right(
      RatingSummaryEntity(
        userId: 'seller-uuid',
        averageRating: 4.8,
        totalReviews: 12,
      ),
    );
  }
}

void main() {
  test('ReviewModel parses json correctly', () {
    final json = {
      'danhgia_id': 10,
      'giaodich_id': 25,
      'nguoi_danh_gia': 'user-1',
      'nguoi_nhan_danh_gia': 'user-2',
      'so_sao': 5,
      'noi_dung': 'Sách rất mới và bạn bán nhiệt tình',
      'ngay_tao': '2026-10-17T08:00:00.000Z',
    };

    final model = ReviewModel.fromJson(json);
    expect(model.reviewId, 10);
    expect(model.transactionId, 25);
    expect(model.reviewerId, 'user-1');
    expect(model.targetUserId, 'user-2');
    expect(model.stars, 5);
    expect(model.content, 'Sách rất mới và bạn bán nhiệt tình');
  });

  test('SubmitReviewUsecase executes repository call', () async {
    final mockRepo = MockReviewRepository();
    final usecase = SubmitReviewUsecase(mockRepo);

    final result = await usecase(
      const SubmitReviewParams(
        transactionId: 25,
        stars: 5,
        content: 'Tuyệt vời',
      ),
    );

    expect(mockRepo.submitReviewCalled, isTrue);
    expect(result.isRight(), isTrue);
    result.match(
      (l) => fail('Should not fail'),
      (review) {
        expect(review.stars, 5);
        expect(review.content, 'Tuyệt vời');
      },
    );
  });
}
