/// Tiện ích xử lý văn bản Tiếng Việt & Tiếng Anh chuẩn UTF-8.
///
/// Hỗ trợ:
/// - Chuẩn hóa chuỗi Unicode tổ hợp (NFD) về dựng sẵn (NFC).
/// - Loại bỏ dấu tiếng Việt (bảo toàn độ dài 1-1 với chuỗi NFC).
/// - Kiểm tra dấu tiếng Việt và tách từ (tokenize) đa ngôn ngữ.
/// - Xác định vùng văn bản khớp (match ranges) để highlight trên UI.
class VietnameseTextUtils {
  VietnameseTextUtils._();

  static const Map<String, List<String>> _vowelFamilies = {
    'a': ['a', 'à', 'á', 'ả', 'ã', 'ạ'],
    'ă': ['ă', 'ằ', 'ắ', 'ẳ', 'ẵ', 'ặ'],
    'â': ['â', 'ầ', 'ấ', 'ẩ', 'ẫ', 'ậ'],
    'e': ['e', 'è', 'é', 'ẻ', 'ẽ', 'ẹ'],
    'ê': ['ê', 'ề', 'ế', 'ể', 'ễ', 'ệ'],
    'i': ['i', 'ì', 'í', 'ỉ', 'ĩ', 'ị'],
    'o': ['o', 'ò', 'ó', 'ỏ', 'õ', 'ọ'],
    'ô': ['ô', 'ồ', 'ố', 'ổ', 'ỗ', 'ộ'],
    'ơ': ['ơ', 'ờ', 'ớ', 'ở', 'ỡ', 'ợ'],
    'u': ['u', 'ù', 'ú', 'ủ', 'ũ', 'ụ'],
    'ư': ['ư', 'ừ', 'ứ', 'ử', 'ữ', 'ự'],
    'y': ['y', 'ỳ', 'ý', 'ỷ', 'ỹ', 'ỵ'],
    'A': ['A', 'À', 'Á', 'Ả', 'Ã', 'Ạ'],
    'Ă': ['Ă', 'Ằ', 'Ắ', 'Ẳ', 'Ẵ', 'Ặ'],
    'Â': ['Â', 'Ầ', 'Ấ', 'Ẩ', 'Ẫ', 'Ậ'],
    'E': ['E', 'È', 'É', 'Ẻ', 'Ẽ', 'Ẹ'],
    'Ê': ['Ê', 'Ề', 'Ế', 'Ể', 'Ễ', 'Ệ'],
    'I': ['I', 'Ì', 'Í', 'Ỉ', 'Ĩ', 'Ị'],
    'O': ['O', 'Ò', 'Ó', 'Ỏ', 'Õ', 'Ọ'],
    'Ô': ['Ô', 'Ồ', 'Ố', 'Ổ', 'Ỗ', 'Ộ'],
    'Ơ': ['Ơ', 'Ờ', 'Ớ', 'Ở', 'Ỡ', 'Ợ'],
    'U': ['U', 'Ù', 'Ú', 'Ủ', 'Ũ', 'Ụ'],
    'Ư': ['Ư', 'Ừ', 'Ứ', 'Ử', 'Ữ', 'Ự'],
    'Y': ['Y', 'Ỳ', 'Ý', 'Ỷ', 'Ỹ', 'Ỵ'],
  };

  static const Map<String, String> _familyToAscii = {
    'a': 'a',
    'ă': 'a',
    'â': 'a',
    'e': 'e',
    'ê': 'e',
    'i': 'i',
    'o': 'o',
    'ô': 'o',
    'ơ': 'o',
    'u': 'u',
    'ư': 'u',
    'y': 'y',
    'A': 'A',
    'Ă': 'A',
    'Â': 'A',
    'E': 'E',
    'Ê': 'E',
    'I': 'I',
    'O': 'O',
    'Ô': 'O',
    'Ơ': 'O',
    'U': 'U',
    'Ư': 'U',
    'Y': 'Y',
  };

  static final Map<String, ({String family, int tone, String ascii})>
  _charLookup = _buildCharLookup();

  static Map<String, ({String family, int tone, String ascii})>
  _buildCharLookup() {
    final map = <String, ({String family, int tone, String ascii})>{};
    for (final entry in _vowelFamilies.entries) {
      final family = entry.key;
      final tones = entry.value;
      final ascii = _familyToAscii[family]!;
      for (var tone = 0; tone < tones.length; tone++) {
        map[tones[tone]] = (family: family, tone: tone, ascii: ascii);
      }
    }
    return map;
  }

  static bool _isCombiningMark(int codeUnit) =>
      codeUnit >= 0x0300 && codeUnit <= 0x036F;

  static int? _combiningMarkToTone(int codeUnit) {
    switch (codeUnit) {
      case 0x0300: // Huyền (`)
        return 1;
      case 0x0301: // Sắc (´)
        return 2;
      case 0x0309: // Hỏi (?)
        return 3;
      case 0x0303: // Ngã (~)
        return 4;
      case 0x0323: // Nặng (.)
        return 5;
      default:
        return null;
    }
  }

  static String _applyModifier(String currentFamily, int modifierCodeUnit) {
    switch (modifierCodeUnit) {
      case 0x0306: // Breve (dấu á)
        if (currentFamily == 'a') return 'ă';
        if (currentFamily == 'A') return 'Ă';
        break;
      case 0x0302: // Circumflex (dấu mũ)
        if (currentFamily == 'a') return 'â';
        if (currentFamily == 'A') return 'Â';
        if (currentFamily == 'e') return 'ê';
        if (currentFamily == 'E') return 'Ê';
        if (currentFamily == 'o') return 'ô';
        if (currentFamily == 'O') return 'Ô';
        break;
      case 0x031B: // Horn (dấu móc)
        if (currentFamily == 'o') return 'ơ';
        if (currentFamily == 'O') return 'Ơ';
        if (currentFamily == 'u') return 'ư';
        if (currentFamily == 'U') return 'Ư';
        break;
    }
    return currentFamily;
  }

  /// Chuẩn hóa chuỗi UTF-8 về dạng dựng sẵn (NFC).
  ///
  /// Giải quyết triệt để lỗi không khớp chuỗi khi một bên là Unicode tổ hợp (NFD)
  /// và một bên là Unicode dựng sẵn (NFC).
  static String normalizeToNfc(String input) {
    if (input.isEmpty) return input;
    final buffer = StringBuffer();
    var i = 0;
    while (i < input.length) {
      final char = input[i];
      final info = _charLookup[char];
      if (info != null) {
        var family = info.family;
        var tone = info.tone;
        while (i + 1 < input.length &&
            _isCombiningMark(input.codeUnitAt(i + 1))) {
          final mark = input.codeUnitAt(i + 1);
          final markTone = _combiningMarkToTone(mark);
          if (markTone != null) {
            tone = markTone;
          } else {
            family = _applyModifier(family, mark);
          }
          i++;
        }
        buffer.write(_vowelFamilies[family]![tone]);
      } else if (_isCombiningMark(input.codeUnitAt(i))) {
        // Bỏ qua các dấu tổ hợp rời không gắn với nguyên âm hợp lệ
      } else {
        buffer.write(char);
      }
      i++;
    }
    return buffer.toString();
  }

  /// Chuyển chuỗi tiếng Việt (NFC hoặc NFD) về chuỗi ASCII không dấu.
  ///
  /// Lưu ý: Nếu đầu vào đã qua [normalizeToNfc], chuỗi kết quả có độ dài
  /// bằng đúng chuỗi đầu vào (ánh xạ ký tự 1-1).
  static String removeDiacritics(String input) {
    if (input.isEmpty) return input;
    final nfc = normalizeToNfc(input);
    final buffer = StringBuffer();
    for (var i = 0; i < nfc.length; i++) {
      final char = nfc[i];
      if (char == 'đ') {
        buffer.write('d');
      } else if (char == 'Đ') {
        buffer.write('D');
      } else {
        final info = _charLookup[char];
        buffer.write(info != null ? info.ascii : char);
      }
    }
    return buffer.toString();
  }

  /// Kiểm tra xem chuỗi có chứa ký tự có dấu tiếng Việt hay không.
  static bool hasVietnameseDiacritics(String input) {
    if (input.isEmpty) return false;
    final nfc = normalizeToNfc(input);
    return nfc != removeDiacritics(nfc);
  }

  /// Tách chuỗi thành danh sách các từ (tokens) đã chuẩn hóa NFC và viết thường.
  static List<String> tokenize(String input) {
    final normalized = normalizeToNfc(input).toLowerCase().trim();
    if (normalized.isEmpty) return const [];
    return RegExp(r'[\p{L}\p{N}]+', unicode: true)
        .allMatches(normalized)
        .map((m) => m.group(0)!)
        .where((t) => t.isNotEmpty)
        .toList(growable: false);
  }

  /// Tìm các khoảng vị trí `[start, end)` trong [text] (sau khi chuẩn hóa NFC)
  /// khớp với câu truy vấn [rawQuery] để phục vụ highlight trên UI.
  ///
  /// Hỗ trợ:
  /// - Tìm không dấu khớp từ có dấu và các từ mở rộng âm tiết
  ///   (ví dụ query `"chu"` sẽ highlight trọn vẹn `"Chủ"`, `"Chũ"`, `"Chù"`, `"Chụ"`, `"Chủi"...`).
  /// - Tìm có dấu khớp chính xác hoặc khớp tiền tố âm tiết.
  static List<({int start, int end})> findMatchRanges(
    String text,
    String rawQuery,
  ) {
    final textNfc = normalizeToNfc(text);
    final queryTokens = tokenize(rawQuery);
    if (textNfc.isEmpty || queryTokens.isEmpty) return const [];

    final textLower = textNfc.toLowerCase();
    final textFolded = removeDiacritics(textLower);

    final rawRanges = <({int start, int end})>[];
    final wordMatches = RegExp(
      r'[\p{L}\p{N}]+',
      unicode: true,
    ).allMatches(textLower);

    for (final wordMatch in wordMatches) {
      final wStart = wordMatch.start;
      final wEnd = wordMatch.end;
      final wordAccented = textLower.substring(wStart, wEnd);
      final wordFolded = textFolded.substring(wStart, wEnd);

      for (final qToken in queryTokens) {
        final qFolded = removeDiacritics(qToken);
        final qHasDiacritics = qToken != qFolded;

        if (qHasDiacritics) {
          if (wordAccented.startsWith(qToken)) {
            rawRanges.add((start: wStart, end: wEnd));
          } else {
            final subIdx = wordAccented.indexOf(qToken);
            if (subIdx != -1) {
              rawRanges.add((
                start: wStart + subIdx,
                end: wStart + subIdx + qToken.length,
              ));
            } else if (wordFolded.startsWith(qFolded)) {
              rawRanges.add((start: wStart, end: wEnd));
            }
          }
        } else {
          if (wordFolded.startsWith(qFolded)) {
            // Highlight trọn vẹn từ/âm tiết bắt đầu bằng token (VD: 'chu' -> 'chủ', 'chủi')
            rawRanges.add((start: wStart, end: wEnd));
          } else {
            final subIdx = wordFolded.indexOf(qFolded);
            if (subIdx != -1) {
              rawRanges.add((
                start: wStart + subIdx,
                end: wStart + subIdx + qFolded.length,
              ));
            }
          }
        }
      }
    }

    if (rawRanges.isEmpty) return const [];

    rawRanges.sort((a, b) {
      final cmp = a.start.compareTo(b.start);
      return cmp != 0 ? cmp : a.end.compareTo(b.end);
    });

    final merged = <({int start, int end})>[rawRanges.first];
    for (var i = 1; i < rawRanges.length; i++) {
      final current = rawRanges[i];
      final last = merged.last;
      if (current.start <= last.end) {
        merged[merged.length - 1] = (
          start: last.start,
          end: current.end > last.end ? current.end : last.end,
        );
      } else {
        merged.add(current);
      }
    }
    return merged;
  }
}
