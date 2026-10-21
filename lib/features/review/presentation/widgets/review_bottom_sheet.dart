import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';

class ReviewInput {
  final int stars;
  final String? content;

  const ReviewInput({required this.stars, this.content});
}

class ReviewBottomSheet extends StatefulWidget {
  const ReviewBottomSheet({
    super.key,
    required this.targetUserName,
    required this.postTitle,
    required this.isEvaluatingSeller,
  });

  final String targetUserName;
  final String postTitle;
  final bool isEvaluatingSeller;

  static Future<ReviewInput?> show({
    required BuildContext context,
    required String targetUserName,
    required String postTitle,
    required bool isEvaluatingSeller,
  }) {
    return showModalBottomSheet<ReviewInput>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorConstants.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ReviewBottomSheet(
        targetUserName: targetUserName,
        postTitle: postTitle,
        isEvaluatingSeller: isEvaluatingSeller,
      ),
    );
  }

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  int _selectedStars = 5;
  final _commentController = TextEditingController();

  static const _starLabels = {
    1: 'Rất tệ',
    2: 'Tệ',
    3: 'Bình thường',
    4: 'Tốt',
    5: 'Tuyệt vời',
  };

  List<String> get _quickChips => widget.isEvaluatingSeller
      ? const [
          'Sách đúng mô tả',
          'Tài liệu rất mới',
          'Đúng giờ hẹn',
          'Giao tiếp nhiệt tình',
        ]
      : const [
          'Đúng giờ hẹn',
          'Giao dịch nhanh gọn',
          'Thân thiện, lịch sự',
          'Uy tín',
        ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addChipText(String text) {
    final current = _commentController.text.trim();
    if (current.isEmpty) {
      _commentController.text = text;
    } else if (!current.contains(text)) {
      _commentController.text = '$current, $text';
    }
    _commentController.selection = TextSelection.fromPosition(
      TextPosition(offset: _commentController.text.length),
    );
    setState(() {});
  }

  void _submit() {
    if (_selectedStars < 1 || _selectedStars > 5) return;
    final comment = _commentController.text.trim();
    Navigator.of(context).pop(
      ReviewInput(
        stars: _selectedStars,
        content: comment.isEmpty ? null : comment,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final roleLabel = widget.isEvaluatingSeller ? 'người bán' : 'người mua';

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: ColorConstants.greyShade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: ColorConstants.orangeShade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: ColorConstants.warningColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đánh giá $roleLabel',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: ColorConstants.textPrimaryColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.targetUserName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ColorConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Post title banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: ColorConstants.greyShade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorConstants.borderLightColor),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      size: 16,
                      color: ColorConstants.textSecondaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.postTitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.textSecondaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Star Rating Row
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final star = index + 1;
                        final isFilled = star <= _selectedStars;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedStars = star),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: AnimatedScale(
                              scale: isFilled ? 1.15 : 1.0,
                              duration: const Duration(milliseconds: 150),
                              child: Icon(
                                isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                                size: 38,
                                color: isFilled
                                    ? ColorConstants.warningColor
                                    : ColorConstants.greyShade300,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _starLabels[_selectedStars] ?? '',
                        key: ValueKey(_selectedStars),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: ColorConstants.warningColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Quick suggestion chips
              const Text(
                'Nhận xét nhanh:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickChips.map((chip) {
                  return ActionChip(
                    label: Text(chip),
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ColorConstants.textPrimaryColor,
                    ),
                    backgroundColor: ColorConstants.greyShade100,
                    side: const BorderSide(color: ColorConstants.borderLightColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    onPressed: () => _addChipText(chip),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Comment text area
              TextField(
                controller: _commentController,
                maxLength: 255,
                maxLines: 3,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Nhận xét về chất lượng sách và thái độ đúng hẹn (không bắt buộc)...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: ColorConstants.greyShade400,
                  ),
                  filled: true,
                  fillColor: ColorConstants.greyShade50,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: ColorConstants.borderLightColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: ColorConstants.borderLightColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: ColorConstants.primaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Actions
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorConstants.textSecondaryColor,
                        side: const BorderSide(color: ColorConstants.borderLightColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Để sau',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.send_rounded, size: 18),
                      style: FilledButton.styleFrom(
                        backgroundColor: ColorConstants.primaryColor,
                        foregroundColor: ColorConstants.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      label: const Text(
                        'Gửi đánh giá',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
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
    );
  }
}
