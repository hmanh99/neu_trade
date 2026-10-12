import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import 'package:neu_trade/core/router/route_paths.dart';

import '../../domain/entities/home_post_entity.dart';
import '../../domain/entities/status.dart';
import '../bloc/post_detail_bloc.dart';
import '../bloc/post_detail_event.dart';
import '../bloc/post_detail_state.dart';
import '../widgets/home_formatters.dart';
import '../widgets/post_bottom_bar.dart';
import '../widgets/post_detail_specs.dart';
import '../widgets/post_image_gallery.dart';
import '../widgets/post_seller_card.dart';
import '../widgets/report_post_bottom_sheet.dart';
import '../widgets/reserve_bottom_sheet.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.postId, this.currentUserId});

  final int postId;
  final String? currentUserId;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PostDetailBloc>().add(PostDetailLoadRequested(widget.postId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostDetailBloc, PostDetailState>(
      listener: (context, state) {
        if (state is PostDetailReserveSuccessState) {
          _showReserveSuccessDialog(context, state.post);
        } else if (state is PostDetailReportSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: ColorConstants.green,
            ),
          );
        } else if (state is PostDetailFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: ColorConstants.errorColor,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is PostDetailLoadingState) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final post = switch (state) {
          PostDetailLoadedState(:final post) => post,
          PostDetailReservingState(:final post) => post,
          PostDetailReserveSuccessState(:final post) => post,
          PostDetailReportingState(:final post) => post,
          PostDetailReportSuccessState(:final post) => post,
          PostDetailFailureState(:final post) => post,
          _ => null,
        };

        if (post == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chi tiết bài đăng')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Không thể tải thông tin bài đăng.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<PostDetailBloc>().add(
                      PostDetailLoadRequested(widget.postId),
                    ),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        final isOwner =
            widget.currentUserId != null &&
            widget.currentUserId == post.authorId;
        final isAvailable = post.status == Status.DangHienThi;

        return Scaffold(
          backgroundColor: ColorConstants.backgroundColor,
          appBar: AppBar(
            backgroundColor: ColorConstants.white,
            foregroundColor: ColorConstants.greyShade900,
            elevation: 0.5,
            title: const Text(
              'Chi tiết bài đăng',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            actions: [
              if (!isOwner)
                IconButton(
                  tooltip: 'Báo cáo bài đăng',
                  onPressed: state is PostDetailReportingState ||
                          state is PostDetailReportSuccessState
                      ? null
                      : () => ReportPostBottomSheet.show(
                            context: context,
                            onSubmit: (reason, description) {
                              context.read<PostDetailBloc>().add(
                                PostDetailReportSubmitted(
                                  postId: post.id,
                                  reason: reason,
                                  description: description,
                                ),
                              );
                            },
                          ),
                  icon: state is PostDetailReportingState
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.report_problem_outlined, size: 22),
                ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image gallery
                PostImageGallery(imageUrls: post.imageUrls),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ColorConstants.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: ColorConstants.greyShade200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              post.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: ColorConstants.greyShade900,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Price
                            Text(
                              HomeFormatters.formatCurrency(
                                post.document.price,
                              ),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: ColorConstants.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Document full name if different from title
                            if (post.document.name.trim() !=
                                post.title.trim()) ...[
                              Text(
                                'Tên sách: ${post.document.name}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: ColorConstants.greyShade700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Seller info card
                      PostSellerCard(
                        authorName: post.authorName,
                        createdAt: post.createdAt,
                        address: post.address,
                        onContactTap: isOwner
                            ? null
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Liên hệ người bán: ${post.authorName}',
                                    ),
                                  ),
                                );
                              },
                      ),
                      const SizedBox(height: 14),

                      // Specs card
                      PostDetailSpecs(
                        document: post.document,
                        address: post.address,
                      ),
                      const SizedBox(height: 14),

                      // Description card
                      if (post.description != null &&
                          post.description!.trim().isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ColorConstants.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: ColorConstants.greyShade200,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mô tả bài đăng',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: ColorConstants.greyShade900,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                post.description!.trim(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: ColorConstants.greyShade800,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: PostBottomBar(
            price: post.document.price,
            isOwner: isOwner,
            isAvailable: isAvailable,
            onReserveTap: () {
              ReserveBottomSheet.show(
                context: context,
                post: post,
                onConfirm: (note) {
                  context.read<PostDetailBloc>().add(
                    PostDetailReserveSubmitted(
                      postId: post.id,
                      meetingLocation: post.address.label,
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

void _showReserveSuccessDialog(BuildContext context, HomePostEntity post) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: ColorConstants.greenShade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            size: 48,
            color: ColorConstants.green,
          ),
        ),
        title: const Text(
          'Đặt trước thành công!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Yêu cầu đặt trước "${post.title}" đã được gửi tới người bán.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: ColorConstants.greyShade700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorConstants.greyShade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.place,
                    size: 18,
                    color: ColorConstants.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Điểm hẹn: ${post.address.label}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.greyShade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Ở lại trang này'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.go(AppRoutePaths.transaction);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.primaryColor,
              foregroundColor: ColorConstants.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Xem giao dịch'),
          ),
        ],
      );
    },
  );
}
