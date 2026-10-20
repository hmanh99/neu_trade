import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import 'package:neu_trade/core/router/route_names.dart';
import '../bloc/home_post_bloc.dart';
import '../bloc/home_post_event.dart';
import '../bloc/home_post_state.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/home_empty_view.dart';
import '../widgets/home_post_card.dart';
import '../widgets/home_post_skeleton.dart';
import '../widgets/home_search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeBloc = context.read<HomeBloc>();
      if (homeBloc.state is HomeInitialState) {
        homeBloc.add(const HomeLoadRequested());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: ColorConstants.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: ColorConstants.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NEU Trade',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: ColorConstants.textPrimaryColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Sàn trao đổi tài liệu sinh viên',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: ColorConstants.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  HomeSearchBar(
                    controller: _searchController,
                    onChanged: (query) {
                      context.read<HomeBloc>().add(HomeSearchQueryChanged(query));
                    },
                    onClear: () {
                      context
                          .read<HomeBloc>()
                          .add(const HomeSearchQueryChanged(''));
                    },
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      final selectedCategory = state is HomeLoadedState
                          ? state.selectedCategory
                          : null;
                      return CategoryFilterBar(
                        selectedCategory: selectedCategory,
                        onCategorySelected: (category) {
                          context
                              .read<HomeBloc>()
                              .add(HomeFilterCategorySelected(category));
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            // Post feed list
            Expanded(
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoadingState || state is HomeInitialState) {
                    return const SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(16),
                      child: HomePostSkeleton(),
                    );
                  }

                  if (state is HomeFailureState) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: ColorConstants.errorColor,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: ColorConstants.greyShade700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                context
                                    .read<HomeBloc>()
                                    .add(const HomeLoadRequested());
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Thử lại'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorConstants.primaryColor,
                                foregroundColor: ColorConstants.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is HomeLoadedState) {
                    if (state.filteredPosts.isEmpty) {
                      final hasFilter = state.selectedCategory != null ||
                          state.searchQuery.isNotEmpty;
                      return HomeEmptyView(
                        message: hasFilter
                            ? 'Không tìm thấy bài đăng nào phù hợp với bộ lọc.'
                            : 'Hiện tại chưa có bài đăng nào trên hệ thống.',
                        actionLabel: hasFilter ? 'Xoá bộ lọc' : 'Làm mới',
                        onAction: () {
                          _searchController.clear();
                          context
                              .read<HomeBloc>()
                              .add(const HomeSearchQueryChanged(''));
                          context
                              .read<HomeBloc>()
                              .add(const HomeFilterCategorySelected(null));
                          if (!hasFilter) {
                            context
                                .read<HomeBloc>()
                                .add(const HomeRefreshRequested());
                          }
                        },
                      );
                    }

                    return RefreshIndicator(
                      color: ColorConstants.primaryColor,
                      onRefresh: () async {
                        context
                            .read<HomeBloc>()
                            .add(const HomeRefreshRequested());
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        itemCount: state.filteredPosts.length,
                        itemBuilder: (context, index) {
                          final post = state.filteredPosts[index];
                          return HomePostCard(
                            post: post,
                            onTap: () {
                              context.pushNamed(
                                AppRouteNames.postDetail,
                                pathParameters: {'id': post.id.toString()},
                                extra: post,
                              );
                            },
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
