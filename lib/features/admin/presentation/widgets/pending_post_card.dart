import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import 'package:neu_trade/features/admin/domain/entities/admin_post_entity.dart';
import 'package:neu_trade/shared/wigdets/formatters.dart';

class PendingPostCard extends StatelessWidget {
  final AdminPostEntity post;
  final bool isProcessing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const PendingPostCard({
    super.key,
    required this.post,
    required this.isProcessing,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = post.imageUrls.isNotEmpty;
    final firstImage = hasImage ? post.imageUrls.first : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorConstants.borderLightColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Seller + Time
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: ColorConstants.blueShade50,
                      child: Text(
                        post.authorName.isNotEmpty
                            ? post.authorName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: ColorConstants.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        post.authorName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.textPrimaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ColorConstants.greyShade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        Formatters.formatRelativeTime(post.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.textSecondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Middle row: Thumbnail + Details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 80,
                        height: 80,
                        color: ColorConstants.greyShade100,
                        child: firstImage != null
                            ? Image.network(
                                firstImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.menu_book_rounded,
                                      color: ColorConstants.greyShade400,
                                      size: 32,
                                    ),
                              )
                            : const Icon(
                                Icons.menu_book_rounded,
                                color: ColorConstants.greyShade400,
                                size: 32,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title + Book Name + Price + Badges
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: ColorConstants.textPrimaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            post.document.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: ColorConstants.textSecondaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            Formatters.formatCurrency(post.document.price),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: ColorConstants.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Chips row: Category + Condition
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildChip(
                      post.document.category.label,
                      Icons.category_outlined,
                    ),
                    _buildChip(
                      post.document.condition.label,
                      Icons.verified_outlined,
                    ),
                    if (post.document.publicationYear != null)
                      _buildChip(
                        'NXB ${post.document.publicationYear}',
                        Icons.event_outlined,
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: ColorConstants.dividerColor),
                const SizedBox(height: 12),

                // Actions row
                if (isProcessing)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: ColorConstants.primaryColor,
                        ),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      // Reject button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onReject,
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: ColorConstants.errorColor,
                          ),
                          label: const Text(
                            'Từ chối',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: ColorConstants.errorColor,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: ColorConstants.redShade200,
                            ),
                            backgroundColor: ColorConstants.redShade50,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Approve button
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onApprove,
                          icon: const Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Duyệt',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ColorConstants.greyShade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: ColorConstants.greyShade600),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: ColorConstants.greyShade700,
            ),
          ),
        ],
      ),
    );
  }
}
