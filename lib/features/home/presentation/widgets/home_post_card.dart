import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import '../../domain/entities/condition.dart';
import '../../domain/entities/home_post_entity.dart';
import 'home_formatters.dart';

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
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: ColorConstants.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorConstants.greyShade200),
        boxShadow: [
          BoxShadow(
            color: ColorConstants.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: ColorConstants.transparent,
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
                                        child: CircularProgressIndicator(strokeWidth: 2),
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
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ColorConstants.black.withAlpha(150),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.photo_library_outlined,
                                  size: 11,
                                  color: ColorConstants.white,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '$imageCount',
                                  style: const TextStyle(
                                    color: ColorConstants.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

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
                      const SizedBox(height: 6),

                      // Title
                      Text(
                        post.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: ColorConstants.greyShade900,
                          height: 1.25,
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
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Location & Author info
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: ColorConstants.greyShade600,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              post.address.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: ColorConstants.greyShade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            HomeFormatters.formatRelativeTime(post.createdAt),
                            style: const TextStyle(
                              fontSize: 11,
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
      color: ColorConstants.greyShade100,
      child: const Center(
        child: Icon(
          Icons.menu_book_rounded,
          color: ColorConstants.greyShade400,
          size: 36,
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: ColorConstants.blue.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: ColorConstants.blue,
        ),
      ),
    );
  }

  Widget _buildConditionBadge(Condition condition) {
    Color bg;
    Color fg;
    switch (condition) {
      case Condition.moi100:
        bg = ColorConstants.green.withValues(alpha: 0.2);
        fg = ColorConstants.green;
        break;
      case Condition.luot:
        bg = ColorConstants.orange.withValues(alpha: 0.2);
        fg = ColorConstants.orange;
        break;
      case Condition.cu:
        bg = ColorConstants.greyShade200;
        fg = ColorConstants.greyShade800;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        condition.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
