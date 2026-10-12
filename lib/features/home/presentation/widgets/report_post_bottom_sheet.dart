import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';

class ReportPostBottomSheet extends StatefulWidget {
  const ReportPostBottomSheet({super.key, required this.onSubmit});

  final void Function(String reason, String? description) onSubmit;

  static Future<void> show({
    required BuildContext context,
    required void Function(String reason, String? description) onSubmit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorConstants.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ReportPostBottomSheet(onSubmit: onSubmit),
    );
  }

  @override
  State<ReportPostBottomSheet> createState() => _ReportPostBottomSheetState();
}

class _ReportPostBottomSheetState extends State<ReportPostBottomSheet> {
  static const _reasonOptions = [
    (
      title: 'Nội dung không phù hợp',
      subtitle: 'Hình ảnh, ngôn từ phản cảm hoặc vi phạm quy định',
      icon: Icons.sentiment_very_dissatisfied_outlined,
    ),
    (
      title: 'Thông tin sai lệch',
      subtitle: 'Sai mô tả, giá sách, tình trạng tài liệu thực tế',
      icon: Icons.info_outline_rounded,
    ),
    (
      title: 'Sản phẩm không tồn tại',
      subtitle: 'Người bán báo đã bán hoặc không có tài liệu',
      icon: Icons.inventory_2_outlined,
    ),
    (
      title: 'Spam hoặc lừa đảo',
      subtitle: 'Bài đăng trùng lặp, tin rác hoặc có dấu hiệu gian lận',
      icon: Icons.warning_amber_rounded,
    ),
    (
      title: 'Khác',
      subtitle: 'Lý do khác cần nêu rõ chi tiết bên dưới',
      icon: Icons.edit_note_rounded,
    ),
  ];

  final _descriptionController = TextEditingController();
  late String _selectedReason;

  @override
  void initState() {
    super.initState();
    _selectedReason = _reasonOptions.first.title;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final description = _descriptionController.text.trim();
    if (_selectedReason == 'Khác' && description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng mô tả chi tiết lý do báo cáo của bạn.'),
          backgroundColor: ColorConstants.errorColor,
        ),
      );
      return;
    }
    Navigator.of(context).pop();
    widget.onSubmit(
      _selectedReason,
      description.isEmpty ? null : description,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(top: 4, bottom: 16),
                  decoration: BoxDecoration(
                    color: ColorConstants.greyShade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: ColorConstants.errorLightColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: ColorConstants.errorColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Báo cáo bài đăng',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ColorConstants.greyShade900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Báo cáo sẽ được bảo mật và gửi tới BQT kiểm duyệt.',
                          style: TextStyle(
                            fontSize: 13,
                            color: ColorConstants.greyShade600,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: ColorConstants.greyShade600,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Reason selection label
              const Text(
                'Chọn lý do báo cáo',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ColorConstants.greyShade800,
                ),
              ),
              const SizedBox(height: 8),

              // Reason options list
              ..._reasonOptions.map((option) {
                final isSelected = _selectedReason == option.title;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ColorConstants.redShade50
                        : ColorConstants.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? ColorConstants.errorColor
                          : ColorConstants.greyShade200,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      setState(() {
                        _selectedReason = option.title;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            option.icon,
                            size: 20,
                            color: isSelected
                                ? ColorConstants.errorColor
                                : ColorConstants.greyShade600,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? ColorConstants.errorColor
                                        : ColorConstants.greyShade900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  option.subtitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: ColorConstants.greyShade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? ColorConstants.errorColor
                                    : ColorConstants.greyShade400,
                                width: isSelected ? 6 : 1.5,
                              ),
                              color: ColorConstants.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),

              // Description text field
              TextField(
                controller: _descriptionController,
                maxLength: 500,
                minLines: 3,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  fontSize: 14,
                  color: ColorConstants.greyShade900,
                ),
                decoration: InputDecoration(
                  labelText: _selectedReason == 'Khác'
                      ? 'Mô tả chi tiết *'
                      : 'Mô tả thêm (không bắt buộc)',
                  labelStyle: TextStyle(
                    color: _selectedReason == 'Khác'
                        ? ColorConstants.errorColor
                        : ColorConstants.greyShade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  hintText: _selectedReason == 'Khác'
                      ? 'Vui lòng cung cấp chi tiết lý do bạn báo cáo bài viết...'
                      : 'Nhập thêm thông tin để hỗ trợ việc kiểm duyệt...',
                  hintStyle: const TextStyle(
                    color: ColorConstants.greyShade400,
                    fontSize: 13,
                  ),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: ColorConstants.greyShade50,
                  counterStyle: const TextStyle(
                    color: ColorConstants.greyShade500,
                    fontSize: 12,
                  ),
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: ColorConstants.greyShade200,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: ColorConstants.greyShade200,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: _selectedReason == 'Khác'
                          ? ColorConstants.errorColor
                          : ColorConstants.primaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Action buttons row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: ColorConstants.greyShade300,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.greyShade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.flag_rounded, size: 18),
                      label: const Text(
                        'Gửi báo cáo',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: ColorConstants.errorColor,
                        foregroundColor: ColorConstants.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
