enum PostHistoryCondition {
  cu,
  luot,
  moi100;

  static PostHistoryCondition fromString(String value) {
    switch (value) {
      case 'Cu':
        return PostHistoryCondition.cu;
      case 'Luot':
        return PostHistoryCondition.luot;
      case 'Moi100':
        return PostHistoryCondition.moi100;
      default:
        throw FormatException('Tình trạng không hợp lệ: $value');
    }
  }

  String toDbString() {
    switch (this) {
      case PostHistoryCondition.cu:
        return 'Cu';
      case PostHistoryCondition.luot:
        return 'Luot';
      case PostHistoryCondition.moi100:
        return 'Moi100';
    }
  }

  String get label {
    switch (this) {
      case PostHistoryCondition.cu:
        return 'Cũ';
      case PostHistoryCondition.luot:
        return 'Lướt';
      case PostHistoryCondition.moi100:
        return 'Mới 100%';
    }
  }
}
