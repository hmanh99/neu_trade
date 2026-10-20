import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';

class CancelTransactionSheet extends StatefulWidget {
  const CancelTransactionSheet({
    super.key,
    required this.postTitle,
    required this.isBuyer,
  });

  final String postTitle;
  final bool isBuyer;

  static Future<String?> show({
    required BuildContext context,
    required String postTitle,
    required bool isBuyer,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => CancelTransactionSheet(
        postTitle: postTitle,
        isBuyer: isBuyer,
      ),
    );
  }

  @override
  State<CancelTransactionSheet> createState() => _CancelTransactionSheetState();
}

class _CancelTransactionSheetState extends State<CancelTransactionSheet> {
  late final List<String> _reasons;
  String _selectedReason = '';
  final TextEditingController _customReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reasons = widget.isBuyer
        ? [
            'Thay đổi ý định, không còn nhu cầu',
            'Không liên lạc được với người bán',
            'Tìm thấy tài liệu khác phù hợp hơn',
            'Hai bên đã thỏa thuận hủy',
            'Lý do khác',
          ]
        : [
            'Tài liệu không còn sẵn sàng',
            'Không liên lạc được với người mua',
            'Hai bên đã thỏa thuận hủy',
            'Lý do khác',
          ];
    _selectedReason = _reasons.first;
  }

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: bottomInset + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorConstants.greyShade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorConstants.redShade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: ColorConstants.redShade700,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Xác nhận hủy giao dịch',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: ColorConstants.textPrimaryColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Warning box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorConstants.redShade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ColorConstants.redShade200,
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: ColorConstants.redShade700,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lưu ý: Thao tác này sẽ giải phóng tài liệu và được cộng vào số lần hủy đơn trong hồ sơ cá nhân của bạn.',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.redShade700,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Post Title reference
              Text(
                'Tài liệu: ${widget.postTitle}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ColorConstants.textPrimaryColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),

              const Text(
                'Vui lòng chọn lý do hủy:',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: ColorConstants.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 8),

              // Reasons radio list
              ..._reasons.map((reason) {
                final isSelected = _selectedReason == reason;
                return InkWell(
                  onTap: () => setState(() => _selectedReason = reason),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ColorConstants.primaryLightBg
                          : ColorConstants.greyShade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? ColorConstants.primaryColor
                            : ColorConstants.borderLightColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          size: 18,
                          color: isSelected
                              ? ColorConstants.primaryColor
                              : ColorConstants.greyShade400,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            reason,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? ColorConstants.primaryColor
                                  : ColorConstants.textPrimaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Custom reason text field
              if (_selectedReason == 'Lý do khác') ...[
                const SizedBox(height: 6),
                TextField(
                  controller: _customReasonController,
                  maxLength: 150,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Nhập lý do cụ thể...',
                    hintStyle: const TextStyle(fontSize: 12.5),
                    filled: true,
                    fillColor: ColorConstants.greyShade50,
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: ColorConstants.borderLightColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: ColorConstants.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(
                          color: ColorConstants.borderLightColor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Quay lại',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.textSecondaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final reason = _selectedReason == 'Lý do khác'
                            ? (_customReasonController.text.trim().isNotEmpty
                                ? _customReasonController.text.trim()
                                : 'Lý do khác')
                            : _selectedReason;
                        Navigator.of(context).pop(reason);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: ColorConstants.redShade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Xác nhận hủy',
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
