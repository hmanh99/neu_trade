import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import 'package:neu_trade/shared/wigdets/formatters.dart';

import '../../domain/entities/post_history_entity.dart';
import 'post_history_status_badge.dart';

class PostHistoryCard extends StatelessWidget {
  const PostHistoryCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.isDeleting = false,
  });

  final PostHistoryEntity post;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl =
        post.imageUrls.isNotEmpty ? post.imageUrls.first : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorConstants.borderLightColor),
        boxShadow: ColorConstants.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: isDeleting ? null : onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 84,
                        height: 84,
                        child: thumbnailUrl != null
                            ? Image.network(
                                thumbnailUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _buildPlaceholder(),
                              )
                            : _buildPlaceholder(),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              PostHistoryStatusBadge(
                                status: post.status,
                                compact: true,
                              ),
                              const Spacer(),
                              Text(
                                Formatters.formatRelativeTime(post.createdAt),
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: ColorConstants.textSecondaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (post.canEdit || post.canDelete) ...[
                                const SizedBox(width: 4),
                                if (isDeleting)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: ColorConstants.primaryColor,
                                    ),
                                  )
                                else
                                  _buildPopupMenu(),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            post.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: ColorConstants.textPrimaryColor,
                              letterSpacing: -0.2,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            post.document.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: ColorConstants.textSecondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: ColorConstants.borderLightColor),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildMetaTag(
                      icon: Icons.category_outlined,
                      label: post.document.category.label,
                    ),
                    const SizedBox(width: 8),
                    _buildMetaTag(
                      icon: Icons.verified_outlined,
                      label: post.document.condition.label,
                    ),
                    const SizedBox(width: 8),
                    _buildMetaTag(
                      icon: Icons.place_outlined,
                      label: post.address.label,
                    ),
                    const Spacer(),
                    Text(
                      post.document.price <= 0
                          ? 'Miễn phí'
                          : Formatters.formatCurrency(post.document.price),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: ColorConstants.primaryColor,
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

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 140),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      icon: const Icon(
        Icons.more_vert_rounded,
        size: 20,
        color: ColorConstants.textSecondaryColor,
      ),
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (context) => [
        if (post.canEdit)
          const PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: ColorConstants.primaryColor,
                ),
                SizedBox(width: 10),
                Text(
                  'Chỉnh sửa',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: ColorConstants.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        if (post.canDelete)
          const PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: ColorConstants.errorColor,
                ),
                SizedBox(width: 10),
                Text(
                  'Xoá bài đăng',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: ColorConstants.errorColor,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMetaTag({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ColorConstants.greyShade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorConstants.borderLightColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: ColorConstants.textSecondaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ColorConstants.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const ColoredBox(
      color: ColorConstants.greyShade100,
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          color: ColorConstants.greyShade400,
          size: 28,
        ),
      ),
    );
  }
}
