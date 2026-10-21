import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:neu_trade/core/error/failure.dart';
import 'package:neu_trade/core/usecase/usecase.dart';
import 'package:neu_trade/features/statistics/data/models/circulation_stat_model.dart';
import 'package:neu_trade/features/statistics/domain/entities/circulation_stat_entity.dart';
import 'package:neu_trade/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:neu_trade/features/statistics/domain/usecases/get_circulation_stats_usecase.dart';

class _MockStatisticsRepository implements StatisticsRepository {
  bool called = false;

  @override
  Future<Either<Failure, List<CirculationStatEntity>>>
  getCirculationStats() async {
    called = true;
    return const Right([
      CirculationStatEntity(
        id: 1,
        termCode: 'THU-2026',
        totalHandedOver: 40,
        totalDonated: 15,
      ),
    ]);
  }
}

void main() {
  group('CirculationStatModel & CirculationStatEntity', () {
    test('parses valid json and computes derived values', () {
      final json = {
        'thongke_id': 3,
        'ky_hoc': 'THU-2026',
        'tong_so_sach_ban': 50,
        'tong_so_sach_tang': 20,
      };

      final model = CirculationStatModel.fromJson(json);
      expect(model.id, 3);
      expect(model.termCode, 'THU-2026');
      expect(model.totalHandedOver, 50);
      expect(model.totalDonated, 20);
      expect(model.totalPaid, 30);
      expect(model.donatedRatio, closeTo(0.4, 1e-6));
      expect(model.termLabel, 'Học kỳ Thu 2026');
      expect(model.termRange, 'Tháng 8 – 12/2026');
    });

    test('handles null/missing fields and zero totalHandedOver safely', () {
      final model = CirculationStatModel.fromJson(const {});
      expect(model.id, 0);
      expect(model.termCode, '');
      expect(model.totalHandedOver, 0);
      expect(model.totalDonated, 0);
      expect(model.totalPaid, 0);
      expect(model.donatedRatio, 0.0);
    });

    test('formats labels and ranges for XUAN, HE, and unknown codes', () {
      const xuan = CirculationStatEntity(
        id: 1,
        termCode: 'XUAN-2027',
        totalHandedOver: 10,
        totalDonated: 5,
      );
      expect(xuan.termLabel, 'Học kỳ Xuân 2027');
      expect(xuan.termRange, 'Tháng 1 – 5/2027');

      const he = CirculationStatEntity(
        id: 2,
        termCode: 'HE-2027',
        totalHandedOver: 8,
        totalDonated: 8,
      );
      expect(he.termLabel, 'Học kỳ Hè 2027');
      expect(he.termRange, 'Tháng 6 – 7/2027');
      expect(he.totalPaid, 0);
      expect(he.donatedRatio, 1.0);

      const unknown = CirculationStatEntity(
        id: 3,
        termCode: 'CUSTOM',
        totalHandedOver: 1,
        totalDonated: 0,
      );
      expect(unknown.termLabel, 'CUSTOM');
      expect(unknown.termRange, '');
    });
  });

  test('GetCirculationStatsUsecase delegates to repository', () async {
    final repo = _MockStatisticsRepository();
    final usecase = GetCirculationStatsUsecase(repo);

    final result = await usecase(const NoParams());
    expect(repo.called, isTrue);
    expect(result.isRight(), isTrue);
    result.match(
      (_) => fail('Expected Right'),
      (list) {
        expect(list, hasLength(1));
        expect(list.first.termCode, 'THU-2026');
      },
    );
  });
}
