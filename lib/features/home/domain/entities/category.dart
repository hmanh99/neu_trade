enum Category {
  giaoTrinh,
  doAn,
  slideIn,
  sachBaiTap;

  /// Convert from the Supabase string to enum.
  static Category fromString(String value) {
    switch (value) {
      case 'GiaoTrinh':
        return Category.giaoTrinh;
      case 'DoAn':
        return Category.doAn;
      case 'SlideIn':
        return Category.slideIn;
      case 'SachBaiTap':
        return Category.sachBaiTap;
      default:
        throw FormatException('Danh mục không hợp lệ: $value');
    }
  }

  /// Convert to the Supabase string.
  String toDbString() {
    switch (this) {
      case Category.giaoTrinh:
        return 'GiaoTrinh';
      case Category.doAn:
        return 'DoAn';
      case Category.sachBaiTap:
        return 'SachBaiTap';
      case Category.slideIn:
        return 'SlideIn';
    }
  }

  /// Human-readable label for the UI.
  String get label {
    switch (this) {
      case Category.giaoTrinh:
        return 'Giáo trình';
      case Category.slideIn:
        return 'Slide in';
      case Category.sachBaiTap:
        return 'Sách bài tập';
      case Category.doAn:
        return 'Đồ án';
    }
  }
}
