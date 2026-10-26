enum PostHistoryStatus {
  daAn,
  dangHienThi,
  daDatGiu,
  daBan;

  static PostHistoryStatus fromString(String value) {
    switch (value) {
      case 'DaAn':
        return PostHistoryStatus.daAn;
      case 'DangHienThi':
        return PostHistoryStatus.dangHienThi;
      case 'DaDatGiu':
        return PostHistoryStatus.daDatGiu;
      case 'DaBan':
        return PostHistoryStatus.daBan;
      default:
        throw FormatException('Trạng thái bài đăng không hợp lệ: $value');
    }
  }

  String toDbString() {
    switch (this) {
      case PostHistoryStatus.daAn:
        return 'DaAn';
      case PostHistoryStatus.dangHienThi:
        return 'DangHienThi';
      case PostHistoryStatus.daDatGiu:
        return 'DaDatGiu';
      case PostHistoryStatus.daBan:
        return 'DaBan';
    }
  }

  String get label {
    switch (this) {
      case PostHistoryStatus.daAn:
        return 'Chờ duyệt';
      case PostHistoryStatus.dangHienThi:
        return 'Đang hiển thị';
      case PostHistoryStatus.daDatGiu:
        return 'Đang đặt giữ';
      case PostHistoryStatus.daBan:
        return 'Đã bán';
    }
  }

  String get description {
    switch (this) {
      case PostHistoryStatus.daAn:
        return 'Bài đăng đang chờ quản trị viên phê duyệt trước khi hiển thị công khai.';
      case PostHistoryStatus.dangHienThi:
        return 'Bài đăng đang hiển thị công khai trên trang chủ và sẵn sàng giao dịch.';
      case PostHistoryStatus.daDatGiu:
        return 'Tài liệu đang được người mua đặt giữ chỗ. Bạn có thể quản lý giao dịch tại tab Giao dịch.';
      case PostHistoryStatus.daBan:
        return 'Tài liệu đã được giao dịch thành công.';
    }
  }

  String get lockReason {
    switch (this) {
      case PostHistoryStatus.daAn:
      case PostHistoryStatus.dangHienThi:
        return '';
      case PostHistoryStatus.daDatGiu:
        return 'Không thể chỉnh sửa hoặc xoá bài đăng khi đang có người đặt giữ chỗ. Vui lòng xử lý giao dịch tại tab Giao dịch trước.';
      case PostHistoryStatus.daBan:
        return 'Bài đăng đã hoàn tất giao dịch nên được lưu trữ cố định trong lịch sử.';
    }
  }
}
