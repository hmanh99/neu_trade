import 'package:neu_trade/core/utils/vietnamese_text_utils.dart';
import 'package:neu_trade/features/home/domain/entities/category.dart';
import 'package:neu_trade/features/home/domain/entities/home_post_entity.dart';

/// Dịch vụ tìm kiếm và xếp hạng tin đăng chuẩn UTF-8 (Tiếng Việt & Tiếng Anh).
class HomeSearchService {
  HomeSearchService._();

  /// Lọc danh sách bài đăng theo [category] và từ khóa [rawQuery],
  /// đồng thời sắp xếp theo độ liên quan (Relevance Score) giảm dần.
  static List<HomePostEntity> filterAndRankPosts({
    required List<HomePostEntity> posts,
    Category? category,
    required String rawQuery,
  }) {
    final categoryFiltered = category == null
        ? posts
        : posts
              .where((post) => post.document.category == category)
              .toList(growable: false);

    final queryNfc = VietnameseTextUtils.normalizeToNfc(rawQuery)
        .toLowerCase()
        .trim();
    final queryTokens = VietnameseTextUtils.tokenize(queryNfc);

    if (queryTokens.isEmpty) {
      return List<HomePostEntity>.unmodifiable(categoryFiltered);
    }

    final queryFolded = VietnameseTextUtils.removeDiacritics(queryNfc);
    final scoredPosts = <({HomePostEntity post, double score})>[];

    for (final post in categoryFiltered) {
      final score = scorePost(
        post: post,
        queryNfc: queryNfc,
        queryFolded: queryFolded,
        queryTokens: queryTokens,
      );
      if (score > 0) {
        scoredPosts.add((post: post, score: score));
      }
    }

    scoredPosts.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      return b.post.createdAt.compareTo(a.post.createdAt);
    });

    return scoredPosts.map((entry) => entry.post).toList(growable: false);
  }

  /// Tính điểm độ liên quan của một [post] với truy vấn tìm kiếm.
  /// Trả về `0` nếu bài đăng không khớp đủ các từ khóa trong truy vấn.
  static double scorePost({
    required HomePostEntity post,
    required String queryNfc,
    required String queryFolded,
    required List<String> queryTokens,
  }) {
    final fields = <({String text, double weight})>[
      (text: post.document.name, weight: 3.0),
      (text: post.title, weight: 2.5),
      (text: post.document.category.label, weight: 1.5),
      (text: post.address.label, weight: 1.5),
      (text: post.authorName, weight: 1.2),
      if (post.description != null && post.description!.isNotEmpty)
        (text: post.description!, weight: 1.0),
      if (post.document.conditionNote != null &&
          post.document.conditionNote!.isNotEmpty)
        (text: post.document.conditionNote!, weight: 1.0),
      (text: post.document.condition.label, weight: 1.0),
    ];

    final preparedFields = fields
        .map((f) {
          final nfcLower = VietnameseTextUtils.normalizeToNfc(
            f.text,
          ).toLowerCase();
          final folded = VietnameseTextUtils.removeDiacritics(nfcLower);
          final wordsAccented = VietnameseTextUtils.tokenize(nfcLower);
          final wordsFolded = wordsAccented
              .map(VietnameseTextUtils.removeDiacritics)
              .toList(growable: false);
          return (
            nfcLower: nfcLower,
            folded: folded,
            wordsAccented: wordsAccented,
            wordsFolded: wordsFolded,
            weight: f.weight,
          );
        })
        .toList(growable: false);

    var totalScore = 0.0;

    // 1. Điểm khớp từng token (mọi token trong câu tìm kiếm phải xuất hiện ít nhất 1 lần)
    for (final qToken in queryTokens) {
      final qFolded = VietnameseTextUtils.removeDiacritics(qToken);
      final qHasDiacritics = qToken != qFolded;
      var bestTokenScore = 0.0;

      for (final field in preparedFields) {
        final fieldTokenScore = _scoreTokenInField(
          qToken: qToken,
          qFolded: qFolded,
          qHasDiacritics: qHasDiacritics,
          wordsAccented: field.wordsAccented,
          wordsFolded: field.wordsFolded,
        ) * field.weight;

        if (fieldTokenScore > bestTokenScore) {
          bestTokenScore = fieldTokenScore;
        }
      }

      if (bestTokenScore <= 0) {
        return 0.0;
      }
      totalScore += bestTokenScore;
    }

    // 2. Điểm thưởng khi khớp nguyên cụm từ (phrase match)
    for (final field in preparedFields) {
      if (field.nfcLower.contains(queryNfc)) {
        totalScore += 100.0 * field.weight;
      } else if (field.folded.contains(queryFolded)) {
        totalScore += 80.0 * field.weight;
      }
    }

    return totalScore;
  }

  static double _scoreTokenInField({
    required String qToken,
    required String qFolded,
    required bool qHasDiacritics,
    required List<String> wordsAccented,
    required List<String> wordsFolded,
  }) {
    var best = 0.0;

    for (var i = 0; i < wordsAccented.length; i++) {
      final wAccented = wordsAccented[i];
      final wFolded = wordsFolded[i];
      var candidate = 0.0;

      if (qHasDiacritics) {
        if (wAccented == qToken) {
          // Khớp chính xác từ có dấu (VD: 'chủ' == 'chủ')
          candidate = 75.0;
        } else if (wAccented.startsWith(qToken)) {
          // Khớp tiền tố âm tiết có dấu (VD: 'chủ' -> 'chủi')
          candidate = 60.0;
        } else if (wFolded == qFolded) {
          // Đề xuất các biến thể thanh điệu cùng gốc (VD: 'chủ' -> 'chũ', 'chù', 'chụ')
          candidate = 45.0;
        } else if (wFolded.startsWith(qFolded)) {
          candidate = 35.0;
        } else if (wAccented.contains(qToken)) {
          candidate = 25.0;
        } else if (wFolded.contains(qFolded)) {
          candidate = 15.0;
        }
      } else {
        if (wAccented == qToken) {
          // Khớp chính xác từ tiếng Anh / không dấu
          candidate = 75.0;
        } else if (wFolded == qFolded) {
          // Khớp âm tiết tiếng Việt mọi dấu (VD: 'chu' -> 'chủ', 'chũ', 'chù', 'chụ', 'chú', 'chữ')
          candidate = 70.0;
        } else if (wFolded.startsWith(qFolded)) {
          // Khớp từ bắt đầu bằng gốc không dấu (VD: 'chu' -> 'chủi', 'chứng', 'chương', 'micro' -> 'microeconomics')
          candidate = 55.0;
        } else if (wFolded.contains(qFolded)) {
          // Khớp chuỗi con bên trong từ
          candidate = 25.0;
        }
      }

      if (candidate > best) {
        best = candidate;
      }
    }

    return best;
  }
}
