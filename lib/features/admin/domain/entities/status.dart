enum Status {
  DangHienThi,
  DaAn,
  DaBan,
  DaDatGiu;

  /// Convert from the Supabase string to enum.
  static Status fromString(String value) {
    switch (value) {
      case 'DangHienThi':
        return Status.DangHienThi;
      case 'DaAn':
        return Status.DaAn;
      case 'DaBan':
        return Status.DaBan;
      case 'DaDatGiu':
        return Status.DaDatGiu;
      default:
        throw FormatException('Tình trạng không hợp lệ: $value');
    }
  }

  /// Convert to the Supabase string.
  String toDbString() {
    switch (this) {
      case Status.DangHienThi:
        return 'DangHienThi';
      case Status.DaAn:
        return 'DaAn';
      case Status.DaBan:
        return 'DaBan';
      case Status.DaDatGiu:
        return 'DaDatGiu';
    }
  }

  /// Human-readable label for the UI.
  String get label {
    switch (this) {
      case Status.DangHienThi:
        return 'Đang hiển thị';
      case Status.DaAn:
        return 'Đã ẩn';
      case Status.DaBan:
        return 'Đã bán';
      case Status.DaDatGiu:
        return 'Đã đặt giữ';
    }
  }
}
