import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import 'package:neu_trade/core/services/post_services.dart';
import 'package:neu_trade/features/home/data/models/home_post_model.dart';
import 'package:neu_trade/features/home/domain/entities/condition.dart';
import 'package:neu_trade/features/home/domain/entities/home_post_entity.dart';
import 'package:neu_trade/features/home/domain/entities/status.dart';
import 'package:neu_trade/shared/wigdets/formatters.dart';

class PostHistorySection extends StatefulWidget {
  const PostHistorySection({
    super.key,
    required this.userId,
    this.refreshVersion = 0,
  });

  final String userId;
  final int refreshVersion;

  @override
  State<PostHistorySection> createState() => _PostHistorySectionState();
}

class _PostHistorySectionState extends State<PostHistorySection> {
  late PostServices _postServices;
  List<HomePostEntity> _posts = const [];
  bool _isLoading = true;
  String? _errorMessage;
  Status? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _postServices = PostServices(userId: widget.userId);
    _loadPosts();
  }

  @override
  void didUpdateWidget(covariant PostHistorySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _postServices = PostServices(userId: widget.userId);
      _loadPosts();
    } else if (oldWidget.refreshVersion != widget.refreshVersion) {
      _loadPosts();
    }
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rows = await _postServices.getPostsByUserId();
      final posts = rows
          .map((row) => HomePostModel.fromJson(row).toEntity())
          .toList(growable: false);
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể tải lịch sử bài đăng. Vui lòng thử lại.';
        _isLoading = false;
      });
    }
  }

  List<HomePostEntity> get _filteredPosts {
    if (_selectedStatus == null) return _posts;
    return _posts
        .where((post) => post.status == _selectedStatus)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPosts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Lịch sử bài đăng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: ColorConstants.textPrimaryColor,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            if (!_isLoading && _errorMessage == null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: ColorConstants.primaryLightBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_posts.length} tin',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ColorConstants.primaryColor,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Status filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildFilterChip(label: 'Tất cả', status: null),
              _buildFilterChip(
                label: 'Đang hiển thị',
                status: Status.DangHienThi,
              ),
              _buildFilterChip(label: 'Chờ duyệt', status: Status.DaAn),
              _buildFilterChip(label: 'Đã đặt giữ', status: Status.DaDatGiu),
              _buildFilterChip(label: 'Đã bán', status: Status.DaBan),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (_isLoading)
          _buildStateContainer(
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: ColorConstants.primaryColor,
                  ),
                ),
              ),
            ),
          )
        else if (_errorMessage != null)
          _buildStateContainer(
            child: Column(
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  size: 36,
                  color: ColorConstants.greyShade400,
                ),
                const SizedBox(height: 10),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: ColorConstants.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _loadPosts,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          )
        else if (filtered.isEmpty)
          _buildStateContainer(
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: ColorConstants.primaryLightBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.article_outlined,
                    size: 26,
                    color: ColorConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _selectedStatus == null
                      ? 'Chưa có bài đăng nào'
                      : 'Không có bài đăng ở trạng thái này',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ColorConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedStatus == null
                      ? 'Các tài liệu bạn đăng bán sẽ hiển thị tại đây.'
                      : 'Hãy thử chọn bộ lọc trạng thái khác.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: ColorConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              for (final post in filtered)
                _PostHistoryCard(
                  post: post,
                  onTap: () => context.push('/app/home/post/${post.id}'),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildFilterChip({required String label, required Status? status}) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: ColorConstants.primaryLightBg,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          fontSize: 12.5,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected
              ? ColorConstants.primaryColor
              : ColorConstants.textSecondaryColor,
        ),
        side: BorderSide(
          color: isSelected
              ? ColorConstants.primaryColor
              : ColorConstants.borderLightColor,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onSelected: (_) => setState(() => _selectedStatus = status),
      ),
    );
  }

  Widget _buildStateContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
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
      child: child,
    );
  }
}

class _PostHistoryCard extends StatelessWidget {
  const _PostHistoryCard({required this.post, required this.onTap});

  final HomePostEntity post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final firstImageUrl = post.imageUrls.isNotEmpty
        ? post.imageUrls.first
        : null;
    final imageCount = post.imageUrls.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorConstants.borderLightColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
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
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 96,
                        height: 104,
                        child: firstImageUrl != null && firstImageUrl.isNotEmpty
                            ? Image.network(
                                firstImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _buildPlaceholder(),
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
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _buildStatusBadge(post.status),
                          _buildConditionBadge(post.document.condition),
                        ],
                      ),
                      const SizedBox(height: 6),
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
                      const SizedBox(height: 5),
                      Text(
                        Formatters.formatCurrency(post.document.price),
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: ColorConstants.primaryColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
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
                          Text(
                            Formatters.formatRelativeTime(post.createdAt),
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
      color: ColorConstants.primaryLightBg,
      child: const Center(
        child: Icon(
          Icons.menu_book_rounded,
          color: ColorConstants.primaryLight,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Status status) {
    final (String text, Color bg, Color fg) = switch (status) {
      Status.DangHienThi => (
        'Đang hiển thị',
        ColorConstants.greenShade50,
        ColorConstants.greenShade700,
      ),
      Status.DaAn => (
        'Chờ duyệt',
        ColorConstants.orangeShade50,
        ColorConstants.orangeShade700,
      ),
      Status.DaDatGiu => (
        'Đã đặt giữ',
        ColorConstants.blueShade50,
        ColorConstants.blueShade700,
      ),
      Status.DaBan => (
        'Đã bán',
        ColorConstants.greyShade100,
        ColorConstants.greyShade700,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildConditionBadge(Condition condition) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: ColorConstants.primaryLightBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        condition.label,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: ColorConstants.primaryColor,
        ),
      ),
    );
  }
}
