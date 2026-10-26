import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import 'package:neu_trade/core/router/route_names.dart';
import 'package:neu_trade/shared/wigdets/formatters.dart';

import '../../domain/entities/post_history_entity.dart';
import '../bloc/post_history_detail_bloc.dart';
import '../bloc/post_history_detail_event.dart';
import '../bloc/post_history_detail_state.dart';
import '../widgets/post_history_delete_dialog.dart';
import '../widgets/post_history_status_badge.dart';

class PostHistoryDetailScreen extends StatefulWidget {
  const PostHistoryDetailScreen({super.key, required this.postId});

  final int postId;

  @override
  State<PostHistoryDetailScreen> createState() =>
      _PostHistoryDetailScreenState();
}

class _PostHistoryDetailScreenState extends State<PostHistoryDetailScreen> {
  int _currentImageIndex = 0;
  PostHistoryEntity? _updatedPostResult;

  @override
  void initState() {
    super.initState();
    context.read<PostHistoryDetailBloc>().add(
      PostHistoryDetailLoadRequested(widget.postId),
    );
  }

  Future<void> _openEdit(PostHistoryEntity post) async {
    final result = await context.pushNamed(
      AppRouteNames.postHistoryEdit,
      pathParameters: {'id': '${post.id}'},
      extra: post,
    );
    if (!mounted) return;
    if (result is PostHistoryEntity) {
      _updatedPostResult = result;
      context.read<PostHistoryDetailBloc>().add(
        PostHistoryDetailUpdated(result),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Đã lưu chỉnh sửa. Bài đăng đang chờ quản trị viên duyệt lại.',
          ),
          backgroundColor: ColorConstants.snackBarSuccessColor,
        ),
      );
    }
  }

  Future<void> _confirmAndDelete(PostHistoryEntity post) async {
    final confirmed = await showPostHistoryDeleteDialog(
      context,
      postTitle: post.title,
    );
    if (!confirmed || !mounted) return;
    context.read<PostHistoryDetailBloc>().add(
      PostHistoryDetailDeleteRequested(post.id),
    );
  }

  void _popWithResult() {
    Navigator.of(context).pop(_updatedPostResult);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _popWithResult();
        }
      },
      child: BlocConsumer<PostHistoryDetailBloc, PostHistoryDetailState>(
        listener: (context, state) {
          if (state is PostHistoryDetailLoadedState &&
              state.actionError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionError!),
                backgroundColor: ColorConstants.snackBarFailedColor,
              ),
            );
          }
          if (state is PostHistoryDetailDeletedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã xoá bài đăng thành công.'),
                backgroundColor: ColorConstants.snackBarSuccessColor,
              ),
            );
            Navigator.of(context).pop(true);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: ColorConstants.backgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: ColorConstants.textPrimaryColor,
                  size: 20,
                ),
                onPressed: _popWithResult,
              ),
              title: const Text(
                'Chi tiết bài đã đăng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: ColorConstants.textPrimaryColor,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            body: _buildBody(context, state),
            bottomNavigationBar: state is PostHistoryDetailLoadedState
                ? _buildBottomBar(context, state)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, PostHistoryDetailState state) {
    if (state is PostHistoryDetailInitialState ||
        state is PostHistoryDetailLoadingState) {
      return const Center(
        child: CircularProgressIndicator(color: ColorConstants.primaryColor),
      );
    }

    if (state is PostHistoryDetailFailureState) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: ColorConstants.greyShade400,
              ),
              const SizedBox(height: 12),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: ColorConstants.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.read<PostHistoryDetailBloc>().add(
                  PostHistoryDetailLoadRequested(widget.postId),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Thử lại'),
                style: FilledButton.styleFrom(
                  backgroundColor: ColorConstants.primaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is PostHistoryDetailLoadedState) {
      final post = state.post;
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          _buildImageGallery(post.imageUrls),
          const SizedBox(height: 16),
          _buildStatusCard(post),
          const SizedBox(height: 16),
          _buildMainInfoCard(post),
          const SizedBox(height: 16),
          _buildDocumentSpecsCard(post),
          if (post.description != null && post.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDescriptionCard(post.description!),
          ],
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildImageGallery(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: ColorConstants.greyShade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ColorConstants.borderLightColor),
        ),
        child: const Center(
          child: Icon(
            Icons.menu_book_rounded,
            size: 56,
            color: ColorConstants.greyShade400,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 280,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: imageUrls.length,
              onPageChanged: (index) {
                setState(() => _currentImageIndex = index);
              },
              itemBuilder: (context, index) {
                return Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const ColoredBox(
                    color: ColorConstants.greyShade100,
                    child: Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 44,
                        color: ColorConstants.greyShade400,
                      ),
                    ),
                  ),
                );
              },
            ),
            if (imageUrls.length > 1)
              Positioned(
                right: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_currentImageIndex + 1}/${imageUrls.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(PostHistoryEntity post) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorConstants.borderLightColor),
        boxShadow: ColorConstants.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Trạng thái bài đăng',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: ColorConstants.textSecondaryColor,
                ),
              ),
              const Spacer(),
              PostHistoryStatusBadge(status: post.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            post.status.description,
            style: const TextStyle(
              fontSize: 13,
              color: ColorConstants.textSecondaryColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfoCard(PostHistoryEntity post) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorConstants.borderLightColor),
        boxShadow: ColorConstants.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: ColorConstants.textPrimaryColor,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                post.document.price <= 0
                    ? 'Miễn phí'
                    : Formatters.formatCurrency(post.document.price),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: ColorConstants.primaryColor,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.access_time_rounded,
                size: 15,
                color: ColorConstants.textSecondaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                Formatters.formatRelativeTime(post.createdAt),
                style: const TextStyle(
                  fontSize: 12.5,
                  color: ColorConstants.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentSpecsCard(PostHistoryEntity post) {
    final doc = post.document;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorConstants.borderLightColor),
        boxShadow: ColorConstants.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin tài liệu',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: ColorConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 14),
          _buildSpecRow(
            icon: Icons.menu_book_outlined,
            label: 'Tên sách / tài liệu',
            value: doc.name,
          ),
          _buildSpecRow(
            icon: Icons.category_outlined,
            label: 'Danh mục',
            value: doc.category.label,
          ),
          _buildSpecRow(
            icon: Icons.verified_outlined,
            label: 'Độ mới',
            value: doc.condition.label,
          ),
          if (doc.publicationYear != null)
            _buildSpecRow(
              icon: Icons.calendar_today_outlined,
              label: 'Năm xuất bản',
              value: '${doc.publicationYear}',
            ),
          _buildSpecRow(
            icon: Icons.place_outlined,
            label: 'Điểm giao dịch NEU',
            value: post.address.label,
          ),
          if (doc.conditionNote != null && doc.conditionNote!.trim().isNotEmpty)
            _buildSpecRow(
              icon: Icons.notes_rounded,
              label: 'Ghi chú tình trạng',
              value: doc.conditionNote!,
              isLast: true,
            ),
        ],
      ),
    );
  }

  Widget _buildSpecRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: ColorConstants.primaryColor),
          const SizedBox(width: 10),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: ColorConstants.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                color: ColorConstants.textPrimaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(String description) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorConstants.borderLightColor),
        boxShadow: ColorConstants.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mô tả chi tiết',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: ColorConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: ColorConstants.textSecondaryColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    PostHistoryDetailLoadedState state,
  ) {
    final post = state.post;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        bottomPadding > 0 ? bottomPadding : 14,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: ColorConstants.borderLightColor),
        ),
      ),
      child: post.canEdit || post.canDelete
          ? Row(
              children: [
                if (post.canDelete)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: state.isDeleting
                          ? null
                          : () => _confirmAndDelete(post),
                      icon: state.isDeleting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ColorConstants.errorColor,
                              ),
                            )
                          : const Icon(Icons.delete_outline_rounded, size: 18),
                      label: Text(
                        state.isDeleting ? 'Đang xoá...' : 'Xoá bài',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorConstants.errorColor,
                        side: const BorderSide(color: ColorConstants.errorColor),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                if (post.canDelete && post.canEdit) const SizedBox(width: 12),
                if (post.canEdit)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: state.isDeleting
                          ? null
                          : () => _openEdit(post),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Chỉnh sửa bài'),
                      style: FilledButton.styleFrom(
                        backgroundColor: ColorConstants.primaryColor,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorConstants.greyShade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ColorConstants.borderLightColor),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 18,
                    color: ColorConstants.textSecondaryColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      post.status.lockReason,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: ColorConstants.textSecondaryColor,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
