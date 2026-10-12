enum Address {
  a1,
  a2,
  b,
  c,
  d,
  d2,
  ktx,
  thuVien;

  /// Convert from the Supabase string to enum.
  static Address fromString(String value) {
    switch (value) {
      case 'A1':
        return Address.a1;
      case 'A2':
        return Address.a2;
      case 'B':
        return Address.b;
      case 'C':
        return Address.c;
      case 'D':
        return Address.d;
      case 'D2':
        return Address.d2;
      case 'KTX':
        return Address.ktx;
      case 'ThuVien':
        return Address.thuVien;
      default:
        throw FormatException('Địa điểm không hợp lệ: $value');
    }
  }

  /// Convert to the Supabase string.
  String toDbString() {
    switch (this) {
      case Address.a1:
        return 'A1';
      case Address.a2:
        return 'A2';
      case Address.b:
        return 'B';
      case Address.c:
        return 'C';
      case Address.d:
        return 'D';
      case Address.d2:
        return 'D2';
      case Address.ktx:
        return 'KTX';
      case Address.thuVien:
        return 'ThuVien';
    }
  }

  /// Human-readable label for the UI.
  String get label {
    switch (this) {
      case Address.a1:
        return 'A1';
      case Address.a2:
        return 'A2';
      case Address.b:
        return 'B';
      case Address.c:
        return 'C';
      case Address.d:
        return 'D';
      case Address.d2:
        return 'D2';
      case Address.ktx:
        return 'KTX';
      case Address.thuVien:
        return 'Thư viện';
    }
  }
}
