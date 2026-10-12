import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import '../../domain/entities/home_document_entity.dart';
import '../../domain/entities/address.dart';

class PostDetailSpecs extends StatelessWidget {
  const PostDetailSpecs({
    super.key,
    required this.document,
    required this.address,
  });

  final HomeDocumentEntity document;
  final Address address;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorConstants.greyShade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin tài liệu',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: ColorConstants.greyShade900,
            ),
          ),
          const SizedBox(height: 12),
          _buildSpecRow(
            icon: Icons.category_outlined,
            title: 'Danh mục',
            value: document.category.label,
          ),
          const Divider(height: 20, color: ColorConstants.greyShade200),
          _buildSpecRow(
            icon: Icons.verified_outlined,
            title: 'Tình trạng',
            value: document.condition.label,
          ),
          if (document.conditionNote != null &&
              document.conditionNote!.trim().isNotEmpty) ...[
            const Divider(height: 20, color: ColorConstants.greyShade200),
            _buildSpecRow(
              icon: Icons.notes_rounded,
              title: 'Ghi chú tình trạng',
              value: document.conditionNote!.trim(),
            ),
          ],
          if (document.publicationYear != null) ...[
            const Divider(height: 20, color: ColorConstants.greyShade200),
            _buildSpecRow(
              icon: Icons.calendar_today_outlined,
              title: 'Năm xuất bản',
              value: '${document.publicationYear}',
            ),
          ],
          const Divider(height: 20, color: ColorConstants.greyShade200),
          _buildSpecRow(
            icon: Icons.place_outlined,
            title: 'Điểm nhận sách NEU',
            value: address.label,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: ColorConstants.greyShade600,
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: ColorConstants.greyShade600,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ColorConstants.greyShade900,
            ),
          ),
        ),
      ],
    );
  }
}
