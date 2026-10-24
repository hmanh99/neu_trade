import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import 'package:neu_trade/features/admin/domain/entities/admin_post_entity.dart';
import 'package:neu_trade/features/admin/presentation/bloc/post_approval_bloc.dart';
import 'package:neu_trade/features/admin/presentation/bloc/post_approval_event.dart';
import 'package:neu_trade/features/admin/presentation/bloc/post_approval_state.dart';
import 'package:neu_trade/features/admin/presentation/widgets/pending_post_card.dart';

class PostApprovalScreen extends StatefulWidget {
  const PostApprovalScreen({super.key});

  @override
  State<PostApprovalScreen> createState() => _PostApprovalScreenState();
}

class _PostApprovalScreenState extends State<PostApprovalScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PostApprovalBloc>().add(const PostApprovalLoadEvent());
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<PostApprovalBloc>();
    final completed = bloc.stream.firstWhere(
      (state) =>
          state is PostApprovalLoadedState || state is PostApprovalErrorState,
    );
    bloc.add(const PostApprovalLoadEvent());
    await completed;
  }

  Future<void> _confirmApprove(AdminPostEntity post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Xác nhận duyệt bài',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Duyệt bài "${post.title}"? Sau khi duyệt, bài đăng sẽ hiển thị công khai trên ứng dụng cho tất cả sinh viên.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
            ),
            child: const Text('Duyệt bài'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<PostApprovalBloc>().add(PostApprovalApproveEvent(post.id));
    }
  }

  Future<void> _confirmReject(AdminPostEntity post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Từ chối bài đăng',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Bài đăng "${post.title}" và toàn bộ tài liệu, hình ảnh liên quan sẽ bị xoá vĩnh viễn khỏi hệ thống.\n\nBạn có chắc chắn muốn từ chối?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: ColorConstants.errorColor,
            ),
            child: const Text('Từ chối & Xoá'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<PostApprovalBloc>().add(PostApprovalRejectEvent(post.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Duyệt bài đăng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ColorConstants.textPrimaryColor,
            letterSpacing: -0.4,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ColorConstants.textPrimaryColor,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Tải lại',
            icon: const Icon(
              Icons.refresh_rounded,
              color: ColorConstants.textPrimaryColor,
            ),
            onPressed: () => context.read<PostApprovalBloc>().add(
              const PostApprovalLoadEvent(),
            ),
          ),
        ],
      ),
      body: BlocConsumer<PostApprovalBloc, PostApprovalState>(
        listener: (context, state) {
          if (state is PostApprovalErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: ColorConstants.snackBarFailedColor,
              ),
            );
          } else if (state is PostApprovalLoadedState &&
              state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: ColorConstants.snackBarSuccessColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PostApprovalLoadingState) {
            return const Center(
              child: CircularProgressIndicator(
                color: ColorConstants.primaryColor,
              ),
            );
          }

          if (state is PostApprovalErrorState && state.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 48,
                    color: ColorConstants.greyShade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: ColorConstants.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context.read<PostApprovalBloc>().add(
                      const PostApprovalLoadEvent(),
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Thử lại'),
                    style: FilledButton.styleFrom(
                      backgroundColor: ColorConstants.primaryColor,
                    ),
                  ),
                ],
              ),
            );
          }

          final posts = switch (state) {
            PostApprovalLoadedState(:final posts) => posts,
            PostApprovalErrorState(:final posts) => posts,
            _ => const <AdminPostEntity>[],
          };

          final processingId = switch (state) {
            PostApprovalLoadedState(:final processingPostId) =>
              processingPostId,
            _ => null,
          };

          if (posts.isEmpty) {
            return RefreshIndicator(
              color: ColorConstants.primaryColor,
              onRefresh: _onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: ColorConstants.blueShade50,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.task_alt_rounded,
                              size: 48,
                              color: ColorConstants.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Không có bài đăng cần duyệt',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: ColorConstants.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Tất cả bài đăng đã được xử lý hoặc hiển thị.',
                            style: TextStyle(
                              fontSize: 13,
                              color: ColorConstants.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: ColorConstants.primaryColor,
            onRefresh: _onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return PendingPostCard(
                  key: ValueKey(post.id),
                  post: post,
                  isProcessing: processingId == post.id,
                  onApprove: () => _confirmApprove(post),
                  onReject: () => _confirmReject(post),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
