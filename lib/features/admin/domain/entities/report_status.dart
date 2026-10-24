enum ReportStatus {
  ChoXuLy,
  DaXuLy,
  BacBo;

  /// Convert from the Supabase string to enum.
  static ReportStatus fromString(String value) {
    switch (value) {
      case 'ChoXuLy':
        return ReportStatus.ChoXuLy;
      case 'DaXuLy':
        return ReportStatus.DaXuLy;
      case 'BacBo':
        return ReportStatus.BacBo;
      default:
        throw FormatException('Tình trạng không hợp lệ: $value');
    }
  }

  /// Convert to the Supabase string.
  String toDbString() {
    switch (this) {
      case ReportStatus.ChoXuLy:
        return 'ChoXuLy';
      case ReportStatus.DaXuLy:
        return 'DaXuLy';
      case ReportStatus.BacBo:
        return 'BacBo';
    }
  }

  /// Human-readable label for the UI.
  String get label {
    switch (this) {
      case ReportStatus.ChoXuLy:
        return 'Chờ xử lý';
      case ReportStatus.DaXuLy:
        return 'Đã xử lý';
      case ReportStatus.BacBo:
        return 'Bác bỏ';
    }
  }
}
