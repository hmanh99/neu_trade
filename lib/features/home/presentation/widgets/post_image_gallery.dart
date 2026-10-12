import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';

class PostImageGallery extends StatefulWidget {
  const PostImageGallery({
    super.key,
    required this.imageUrls,
  });

  final List<String> imageUrls;

  @override
  State<PostImageGallery> createState() => _PostImageGalleryState();
}

class _PostImageGalleryState extends State<PostImageGallery> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openFullScreenViewer(int initialPage) {
    if (widget.imageUrls.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenImageViewer(
          imageUrls: widget.imageUrls,
          initialPage: initialPage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Container(
        height: 280,
        color: ColorConstants.greyShade100,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 64,
                color: ColorConstants.greyShade400,
              ),
              SizedBox(height: 8),
              Text(
                'Người bán chưa đăng ảnh tài liệu',
                style: TextStyle(
                  color: ColorConstants.greyShade600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final url = widget.imageUrls[index];
              return GestureDetector(
                onTap: () => _openFullScreenViewer(index),
                child: Hero(
                  tag: 'post_image_$index',
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: ColorConstants.greyShade100,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: ColorConstants.greyShade100,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                          color: ColorConstants.greyShade400,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.imageUrls.length > 1) ...[
          Positioned(
            bottom: 12,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ColorConstants.black.withAlpha(160),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${_currentIndex + 1} / ${widget.imageUrls.length}',
                style: const TextStyle(
                  color: ColorConstants.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imageUrls.length,
                (index) => Container(
                  width: _currentIndex == index ? 16 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? ColorConstants.white
                        : ColorConstants.white.withAlpha(120),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FullScreenImageViewer extends StatefulWidget {
  const _FullScreenImageViewer({
    required this.imageUrls,
    required this.initialPage,
  });

  final List<String> imageUrls;
  final int initialPage;

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late final PageController _controller;
  late int _page;

  @override
  void initState() {
    super.initState();
    _page = widget.initialPage;
    _controller = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.black,
      appBar: AppBar(
        backgroundColor: ColorConstants.transparent,
        foregroundColor: ColorConstants.white,
        title: Text('${_page + 1} / ${widget.imageUrls.length}'),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.imageUrls.length,
        onPageChanged: (i) => setState(() => _page = i),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: Image.network(
                widget.imageUrls[index],
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}
