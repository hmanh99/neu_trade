enum Status {
  DangGiuCho,
  HoanTat,
  DaHuy;

  /// Convert from the Supabase string to enum.
  static Status fromString(String value) {
    switch (value) {
      case 'DangGiuCho':
        return Status.DangGiuCho;
      case 'HoanTat':
        return Status.HoanTat;
      case 'DaHuy':
        return Status.DaHuy;
      default:
        return Status.DangGiuCho;
    }
  }

  /// Convert to the Supabase string.
  String toDbString() {
    switch (this) {
      case Status.DangGiuCho:
        return 'DangGiuCho';
      case Status.HoanTat:
        return 'HoanTat';
      case Status.DaHuy:
        return 'DaHuy';
    }
  }

  /// Human-readable label for the UI.
  String get label {
    switch (this) {
      case Status.DangGiuCho:
        return 'Đang giữ chỗ';
      case Status.HoanTat:
        return 'Hoàn tất';
      case Status.DaHuy:
        return 'Đã hủy';
    }
  }
}
