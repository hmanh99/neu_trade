enum PostHistoryAddress {
  a1,
  a2,
  b,
  c,
  d,
  d2,
  ktx,
  thuVien;

  static PostHistoryAddress fromString(String value) {
    switch (value) {
      case 'A1':
        return PostHistoryAddress.a1;
      case 'A2':
        return PostHistoryAddress.a2;
      case 'B':
        return PostHistoryAddress.b;
      case 'C':
        return PostHistoryAddress.c;
      case 'D':
        return PostHistoryAddress.d;
      case 'D2':
        return PostHistoryAddress.d2;
      case 'KTX':
        return PostHistoryAddress.ktx;
      case 'ThuVien':
        return PostHistoryAddress.thuVien;
      default:
        throw FormatException('Địa điểm không hợp lệ: $value');
    }
  }

  String toDbString() {
    switch (this) {
      case PostHistoryAddress.a1:
        return 'A1';
      case PostHistoryAddress.a2:
        return 'A2';
      case PostHistoryAddress.b:
        return 'B';
      case PostHistoryAddress.c:
        return 'C';
      case PostHistoryAddress.d:
        return 'D';
      case PostHistoryAddress.d2:
        return 'D2';
      case PostHistoryAddress.ktx:
        return 'KTX';
      case PostHistoryAddress.thuVien:
        return 'ThuVien';
    }
  }

  String get label {
    switch (this) {
      case PostHistoryAddress.a1:
        return 'A1';
      case PostHistoryAddress.a2:
        return 'A2';
      case PostHistoryAddress.b:
        return 'B';
      case PostHistoryAddress.c:
        return 'C';
      case PostHistoryAddress.d:
        return 'D';
      case PostHistoryAddress.d2:
        return 'D2';
      case PostHistoryAddress.ktx:
        return 'KTX';
      case PostHistoryAddress.thuVien:
        return 'Thư viện';
    }
  }
}
