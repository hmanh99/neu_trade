enum PostHistoryCategory {
  giaoTrinh,
  doAn,
  slideIn,
  sachBaiTap;

  static PostHistoryCategory fromString(String value) {
    switch (value) {
      case 'GiaoTrinh':
        return PostHistoryCategory.giaoTrinh;
      case 'DoAn':
        return PostHistoryCategory.doAn;
      case 'SlideIn':
        return PostHistoryCategory.slideIn;
      case 'SachBaiTap':
        return PostHistoryCategory.sachBaiTap;
      default:
        throw FormatException('Danh mục không hợp lệ: $value');
    }
  }

  String toDbString() {
    switch (this) {
      case PostHistoryCategory.giaoTrinh:
        return 'GiaoTrinh';
      case PostHistoryCategory.doAn:
        return 'DoAn';
      case PostHistoryCategory.sachBaiTap:
        return 'SachBaiTap';
      case PostHistoryCategory.slideIn:
        return 'SlideIn';
    }
  }

  String get label {
    switch (this) {
      case PostHistoryCategory.giaoTrinh:
        return 'Giáo trình';
      case PostHistoryCategory.slideIn:
        return 'Slide in';
      case PostHistoryCategory.sachBaiTap:
        return 'Sách bài tập';
      case PostHistoryCategory.doAn:
        return 'Đồ án';
    }
  }
}
