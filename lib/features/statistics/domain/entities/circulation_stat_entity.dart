import 'package:equatable/equatable.dart';

class CirculationStatEntity extends Equatable {
  final int id;
  final String termCode;
  final int totalHandedOver;
  final int totalDonated;

  const CirculationStatEntity({
    required this.id,
    required this.termCode,
    required this.totalHandedOver,
    required this.totalDonated,
  });

  int get totalPaid {
    final diff = totalHandedOver - totalDonated;
    return diff < 0 ? 0 : diff;
  }

  double get donatedRatio {
    if (totalHandedOver <= 0) return 0.0;
    final ratio = totalDonated / totalHandedOver;
    if (ratio < 0.0) return 0.0;
    if (ratio > 1.0) return 1.0;
    return ratio;
  }

  String get termLabel {
    final parts = termCode.split('-');
    if (parts.length != 2) return termCode;
    final season = parts[0].toUpperCase();
    final year = parts[1];
    return switch (season) {
      'THU' => 'Học kỳ Thu $year',
      'XUAN' => 'Học kỳ Xuân $year',
      'HE' => 'Học kỳ Hè $year',
      _ => termCode,
    };
  }

  String get termRange {
    final parts = termCode.split('-');
    if (parts.length != 2) return '';
    final season = parts[0].toUpperCase();
    final year = parts[1];
    return switch (season) {
      'THU' => 'Tháng 8 – 12/$year',
      'XUAN' => 'Tháng 1 – 5/$year',
      'HE' => 'Tháng 6 – 7/$year',
      _ => '',
    };
  }

  @override
  List<Object?> get props => [id, termCode, totalHandedOver, totalDonated];
}
