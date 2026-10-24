import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import '../../domain/entities/condition.dart';
import '../../domain/entities/home_post_entity.dart';
import '../../../../shared/home_formatters.dart';

class HomePostCard extends StatelessWidget {
  const HomePostCard({
    super.key,
    required this.post,
    required this.onTap,
  });

  final HomePostEntity post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final firstImageUrl = post.imageUrls.isNotEmpty ? post.imageUrls.first : null;
    final imageCount = post.imageUrls.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorConstants.borderLightColor, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
          BoxShadow(
            color: Color(0x030F172A),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail image with count indicator
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 105,
                        height: 115,
                        child: firstImageUrl != null && firstImageUrl.isNotEmpty
                            ? Image.network(
                                firstImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _buildPlaceholder(),
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Container(
                                    color: ColorConstants.greyShade100,
                                    child: const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: ColorConstants.primaryColor,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : _buildPlaceholder(),
                      ),
                      if (imageCount > 1)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xCC0F172A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.photo_library_rounded,
                                  size: 11,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '$imageCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Post info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges: Category & Condition
                      Row(
                        children: [
                          _buildCategoryBadge(post.document.category.label),
                          const SizedBox(width: 6),
                          _buildConditionBadge(post.document.condition),
                        ],
                      ),
                      const SizedBox(height: 7),

                      // Title
                      Text(
                        post.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: ColorConstants.textPrimaryColor,
                          letterSpacing: -0.2,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Price
                      Text(
                        HomeFormatters.formatCurrency(post.document.price),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: ColorConstants.primaryColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 7),

                      // Location & Author info
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 13,
                            color: ColorConstants.primaryColor,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              post.address.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: ColorConstants.textSecondaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: ColorConstants.greyShade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            HomeFormatters.formatRelativeTime(post.createdAt),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: ColorConstants.greyShade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: ColorConstants.primaryLightBg,
      child: const Center(
        child: Icon(
          Icons.menu_book_rounded,
          color: ColorConstants.primaryLight,
          size: 34,
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: ColorConstants.primaryLightBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: ColorConstants.primaryColor,
        ),
      ),
    );
  }

  Widget _buildConditionBadge(Condition condition) {
    Color bg;
    Color fg;
    switch (condition) {
      case Condition.moi100:
        bg = ColorConstants.greenShade50;
        fg = ColorConstants.greenShade600;
        break;
      case Condition.luot:
        bg = ColorConstants.orangeShade50;
        fg = ColorConstants.orangeShade700;
        break;
      case Condition.cu:
        bg = ColorConstants.greyShade100;
        fg = ColorConstants.greyShade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: fg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            condition.label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
