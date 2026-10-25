import 'package:neu_trade/features/admin/domain/entities/circulation_stat_entity.dart';

class CirculationStatModel extends CirculationStatEntity {
  const CirculationStatModel({
    required super.id,
    required super.termCode,
    required super.totalHandedOver,
    required super.totalDonated,
  });

  factory CirculationStatModel.fromJson(Map<String, dynamic> json) {
    return CirculationStatModel(
      id: (json['thongke_id'] as num?)?.toInt() ?? 0,
      termCode: json['ky_hoc'] as String? ?? '',
      totalHandedOver: (json['tong_so_sach_ban'] as num?)?.toInt() ?? 0,
      totalDonated: (json['tong_so_sach_tang'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'thongke_id': id,
    'ky_hoc': termCode,
    'tong_so_sach_ban': totalHandedOver,
    'tong_so_sach_tang': totalDonated,
  };

  CirculationStatEntity toEntity() => CirculationStatEntity(
    id: id,
    termCode: termCode,
    totalHandedOver: totalHandedOver,
    totalDonated: totalDonated,
  );
}
