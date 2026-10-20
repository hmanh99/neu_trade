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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorConstants.borderLightColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x050F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ColorConstants.primaryLightBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  size: 18,
                  color: ColorConstants.primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Thông tin tài liệu',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: ColorConstants.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSpecRow(
            icon: Icons.category_rounded,
            title: 'Danh mục',
            value: document.category.label,
          ),
          const Divider(height: 20, color: ColorConstants.dividerColor),
          _buildSpecRow(
            icon: Icons.verified_rounded,
            title: 'Tình trạng',
            value: document.condition.label,
          ),
          if (document.conditionNote != null &&
              document.conditionNote!.trim().isNotEmpty) ...[
            const Divider(height: 20, color: ColorConstants.dividerColor),
            _buildSpecRow(
              icon: Icons.notes_rounded,
              title: 'Ghi chú tình trạng',
              value: document.conditionNote!.trim(),
            ),
          ],
          if (document.publicationYear != null) ...[
            const Divider(height: 20, color: ColorConstants.dividerColor),
            _buildSpecRow(
              icon: Icons.calendar_today_rounded,
              title: 'Năm xuất bản',
              value: '${document.publicationYear}',
            ),
          ],
          const Divider(height: 20, color: ColorConstants.dividerColor),
          _buildSpecRow(
            icon: Icons.place_rounded,
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
          color: ColorConstants.primaryColor,
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13.5,
            color: ColorConstants.textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: ColorConstants.textPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
