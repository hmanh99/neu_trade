enum Condition {
  cu,
  luot,
  moi100;

  /// Convert from the Supabase string to enum.
  static Condition fromString(String value) {
    switch (value) {
      case 'Cu':
        return Condition.cu;
      case 'Luot':
        return Condition.luot;
      case 'Moi100':
        return Condition.moi100;
      default:
        throw FormatException('Tình trạng không hợp lệ: $value');
    }
  }

  /// Convert to the Supabase string.
  String toDbString() {
    switch (this) {
      case Condition.cu:
        return 'Cu';
      case Condition.luot:
        return 'Luot';
      case Condition.moi100:
        return 'Moi100';
    }
  }

  /// Human-readable label for the UI.
  String get label {
    switch (this) {
      case Condition.cu:
        return 'Cũ';
      case Condition.luot:
        return 'Lướt';
      case Condition.moi100:
        return 'Mới 100%';
    }
  }
}
