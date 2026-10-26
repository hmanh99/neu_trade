import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import 'package:neu_trade/core/router/route_names.dart';
import 'package:neu_trade/core/router/route_paths.dart';
import 'package:neu_trade/shared/wigdets/main_shell.dart';

import '../../domain/entities/post_history_entity.dart';
import '../bloc/post_history_bloc.dart';
import '../bloc/post_history_event.dart';
import '../bloc/post_history_state.dart';
import '../widgets/post_history_card.dart';
import '../widgets/post_history_delete_dialog.dart';
import '../widgets/post_history_empty_view.dart';
import '../widgets/post_history_skeleton.dart';
import '../widgets/post_history_status_filter_bar.dart';
import '../widgets/post_history_summary_header.dart';

class PostHistoryScreen extends StatefulWidget {
  const PostHistoryScreen({super.key});

  @override
  State<PostHistoryScreen> createState() => _PostHistoryScreenState();
}

class _PostHistoryScreenState extends State<PostHistoryScreen> {
  static const int _historyBranchIndex = 2;

  ValueNotifier<int>? _tabNotifier;
  int? _lastTabIndex;

  @override
  void initState() {
    super.initState();
    context.read<PostHistoryBloc>().add(const PostHistoryLoadRequested());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = ShellTabScope.maybeOf(context);
    if (_tabNotifier != notifier) {
      _tabNotifier?.removeListener(_handleTabChanged);
      _tabNotifier = notifier;
      _lastTabIndex = notifier?.value;
      _tabNotifier?.addListener(_handleTabChanged);
    }
  }

  @override
  void dispose() {
    _tabNotifier?.removeListener(_handleTabChanged);
    super.dispose();
  }

  void _handleTabChanged() {
    final current = _tabNotifier?.value;
    if (current == _historyBranchIndex &&
        _lastTabIndex != _historyBranchIndex &&
        mounted) {
      context.read<PostHistoryBloc>().add(const PostHistoryRefreshRequested());
    }
    _lastTabIndex = current;
  }

  Future<void> _openDetail(PostHistoryEntity post) async {
    final result = await context.pushNamed(
      AppRouteNames.postHistoryDetail,
      pathParameters: {'id': '${post.id}'},
      extra: post,
    );
    if (!mounted) return;
    if (result is PostHistoryEntity) {
      context.read<PostHistoryBloc>().add(PostHistoryPostUpdated(result));
    } else if (result == true) {
      context.read<PostHistoryBloc>().add(const PostHistoryRefreshRequested());
    }
  }

  Future<void> _openEdit(PostHistoryEntity post) async {
    final result = await context.pushNamed(
      AppRouteNames.postHistoryEdit,
      pathParameters: {'id': '${post.id}'},
      extra: post,
    );
    if (!mounted) return;
    if (result is PostHistoryEntity) {
      context.read<PostHistoryBloc>().add(PostHistoryPostUpdated(result));
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
    context.read<PostHistoryBloc>().add(PostHistoryDeleteRequested(post.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostHistoryBloc, PostHistoryState>(
      listener: (context, state) {
        if (state is PostHistoryLoadedState && state.actionMessage != null) {
          final msg = state.actionMessage!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg.message),
              backgroundColor: msg.isError
                  ? ColorConstants.snackBarFailedColor
                  : ColorConstants.snackBarSuccessColor,
            ),
          );
          context.read<PostHistoryBloc>().add(
            const PostHistoryActionMessageCleared(),
          );
        }
      },
      builder: (context, state) {
        final selectedStatus = state is PostHistoryLoadedState
            ? state.selectedStatus
            : null;
        final isLoading = state is PostHistoryLoadingState;

        return Scaffold(
          backgroundColor: ColorConstants.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: const Text(
              'Lịch sử bài đăng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: ColorConstants.textPrimaryColor,
                letterSpacing: -0.4,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Làm mới',
                onPressed: isLoading
                    ? null
                    : () => context.read<PostHistoryBloc>().add(
                        const PostHistoryRefreshRequested(),
                      ),
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: ColorConstants.textPrimaryColor,
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              PostHistoryStatusFilterBar(
                selectedStatus: selectedStatus,
                onStatusSelected: (status) {
                  context.read<PostHistoryBloc>().add(
                    PostHistoryStatusFilterSelected(status),
                  );
                },
              ),
              const Divider(height: 1, color: ColorConstants.borderLightColor),
              if (state is PostHistoryLoadedState &&
                  state.allPosts.isNotEmpty)
                PostHistorySummaryHeader(
                  state: state,
                  onStatusTap: (status) {
                    context.read<PostHistoryBloc>().add(
                      PostHistoryStatusFilterSelected(status),
                    );
                  },
                ),
              Expanded(child: _buildBody(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, PostHistoryState state) {
    if (state is PostHistoryInitialState || state is PostHistoryLoadingState) {
      return const PostHistorySkeleton();
    }

    if (state is PostHistoryFailureState) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
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
                onPressed: () => context.read<PostHistoryBloc>().add(
                  const PostHistoryLoadRequested(),
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

    if (state is PostHistoryLoadedState) {
      if (state.filteredPosts.isEmpty) {
        return RefreshIndicator(
          color: ColorConstants.primaryColor,
          onRefresh: () async {
            context.read<PostHistoryBloc>().add(
              const PostHistoryRefreshRequested(),
            );
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.56,
                child: PostHistoryEmptyView(
                  selectedStatus: state.selectedStatus,
                  onClearFilter: () => context.read<PostHistoryBloc>().add(
                    const PostHistoryStatusFilterSelected(null),
                  ),
                  onUploadTap: () => context.go(AppRoutePaths.upload),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: ColorConstants.primaryColor,
        onRefresh: () async {
          context.read<PostHistoryBloc>().add(
            const PostHistoryRefreshRequested(),
          );
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: state.filteredPosts.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final post = state.filteredPosts[index];
            return PostHistoryCard(
              post: post,
              isDeleting: state.deletingPostId == post.id,
              onTap: () => _openDetail(post),
              onEdit: () => _openEdit(post),
              onDelete: () => _confirmAndDelete(post),
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
