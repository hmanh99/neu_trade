import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';

class HomePostSkeleton extends StatefulWidget {
  const HomePostSkeleton({super.key});

  @override
  State<HomePostSkeleton> createState() => _HomePostSkeletonState();
}

class _HomePostSkeletonState extends State<HomePostSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final shimmerColor = ColorConstants.greyShade300.withAlpha(
          (_animation.value * 255).round(),
        );

        return Column(
          children: List.generate(
            4,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorConstants.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ColorConstants.greyShade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 105,
                    height: 115,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 16,
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 50,
                              height: 16,
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 140,
                          height: 16,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 80,
                          height: 18,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
