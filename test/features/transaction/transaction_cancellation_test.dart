import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/features/home/domain/entities/address.dart';
import 'package:neu_trade/features/profile/data/models/user_public_stats_model.dart';
import 'package:neu_trade/features/transaction/data/models/transaction_model.dart';
import 'package:neu_trade/features/transaction/domain/entities/status.dart';
import 'package:neu_trade/features/transaction/domain/entities/transaction_entity.dart';
import 'package:neu_trade/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:neu_trade/features/transaction/domain/usecases/cancel_transaction_usecase.dart';

class MockTransactionRepository implements TransactionRepository {
  bool cancelCalled = false;
  int? lastCancelledId;
  String? lastCancelReason;

  @override
  Future<Either<Failure, TransactionEntity>> cancelTransaction({
    required int transactionId,
    String? reason,
  }) async {
    cancelCalled = true;
    lastCancelledId = transactionId;
    lastCancelReason = reason;

    return Right(
      TransactionEntity(
        transactionId: transactionId,
        postId: 101,
        buyerId: 'buyer-uuid-1',
        buyerName: 'Nguyễn Văn A',
        sellerId: 'seller-uuid-2',
        sellerName: 'Trần Thị B',
        postTitle: 'Giáo trình Kinh tế vi mô',
        price: 50000,
        address: Address.ktx,
        orderTime: DateTime(2026, 10, 20, 10, 0),
        expireTime: DateTime(2026, 10, 22, 10, 0),
        status: Status.DaHuy,
        cancelledById: 'buyer-uuid-1',
        cancelReason: reason,
        cancelledAt: DateTime(2026, 10, 21, 14, 0),
      ),
    );
  }

  @override
  Future<Either<Failure, TransactionEntity>> completeTransaction({
    required int transactionId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TransactionEntity>> createTransaction({
    required int postId,
    String? note,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction({
    required int transactionId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions() async {
    throw UnimplementedError();
  }
}

void main() {
  group('Cancellation feature tests', () {
    test('TransactionModel parses cancellation fields correctly', () {
      final json = {
        'giaodich_id': 12,
        'tindang_id': 34,
        'nguoi_mua_id': 'buyer-1',
        'ten_nguoi_mua': 'Lê Hoàng',
        'nguoi_dang_id': 'seller-2',
        'ten_nguoi_ban': 'Phạm Nga',
        'tieu_de_tin': 'Nguyên lý kế toán 1',
        'tong_tien': 65000,
        'dia_chi': 'KTX',
        'thoi_gian_dat': '2026-10-20T08:00:00.000Z',
        'thoi_gian_het_han': '2026-10-22T08:00:00.000Z',
        'trang_thai_gd': 'DaHuy',
        'nguoi_huy_id': 'buyer-1',
        'ly_do_huy': 'Đổi ý không mua nữa',
        'thoi_gian_huy': '2026-10-20T10:30:00.000Z',
      };

      final model = TransactionModel.fromJson(json);

      expect(model.transactionId, 12);
      expect(model.status, Status.DaHuy);
      expect(model.cancelledById, 'buyer-1');
      expect(model.cancelReason, 'Đổi ý không mua nữa');
      expect(model.cancelledAt, isNotNull);
      expect(model.cancelledAt, DateTime.parse('2026-10-20T10:30:00.000Z'));
    });

    test('UserPublicStatsModel parses stats correctly', () {
      final json = {
        'sinhvien_id': 'sv-uuid-1',
        'diem_trung_binh': 4.7,
        'tong_danh_gia': 15,
        'so_lan_huy_don': 2,
        'tong_hoan_tat': 8,
      };

      final stats = UserPublicStatsModel.fromJson(json);

      expect(stats.userId, 'sv-uuid-1');
      expect(stats.averageRating, 4.7);
      expect(stats.totalReviews, 15);
      expect(stats.cancelledOrderCount, 2);
      expect(stats.totalCompleted, 8);
    });

    test('CancelTransactionUsecase executes cancel call on repository', () async {
      final repo = MockTransactionRepository();
      final usecase = CancelTransactionUsecase(repo);

      final result = await usecase(
        const CancelTransactionParams(
          transactionId: 12,
          reason: 'Hai bên đã thỏa thuận hủy',
        ),
      );

      expect(repo.cancelCalled, isTrue);
      expect(repo.lastCancelledId, 12);
      expect(repo.lastCancelReason, 'Hai bên đã thỏa thuận hủy');
      expect(result.isRight(), isTrue);

      result.match(
        (l) => fail('Should not fail'),
        (tx) {
          expect(tx.status, Status.DaHuy);
          expect(tx.cancelledById, 'buyer-uuid-1');
          expect(tx.cancelReason, 'Hai bên đã thỏa thuận hủy');
        },
      );
    });
  });
}
