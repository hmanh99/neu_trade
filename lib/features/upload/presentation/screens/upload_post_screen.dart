import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import 'package:neu_trade/core/router/route_paths.dart';

import '../../domain/entities/address.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/condition.dart';
import '../../domain/entities/create_upload_post_request.dart';
import '../bloc/upload_post_bloc.dart';
import '../bloc/upload_post_event.dart';
import '../bloc/upload_post_state.dart';
import '../widgets/upload_post_image_picker.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _documentName = TextEditingController();
  final _publicationYear = TextEditingController();
  final _conditionNote = TextEditingController();
  final _price = TextEditingController();
  final _title = TextEditingController();
  final _description = TextEditingController();

  Category _category = Category.giaoTrinh;
  Condition _condition = Condition.luot;
  Address _address = Address.a2;
  List<XFile> _images = const [];

  @override
  void dispose() {
    _documentName.dispose();
    _publicationYear.dispose();
    _conditionNote.dispose();
    _price.dispose();
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một ảnh tài liệu.'),
          backgroundColor: ColorConstants.snackBarFailedColor,
        ),
      );
      return;
    }

    try {
      final images = await Future.wait(_images.map(_readImage));
      if (!mounted) return;
      context.read<PostBloc>().add(
        PostSubmissionRequested(
          input: CreatePostRequest(
            document: CreateDocumentRequest(
              category: _category,
              name: _documentName.text.trim(),
              condition: _condition,
              price: _price.text.trim().replaceAll(',', '.'),
              publicationYear: _nullableInt(_publicationYear.text),
              conditionNote: _nullableText(_conditionNote.text),
            ),
            title: _title.text.trim(),
            description: _nullableText(_description.text),
            address: _address,
          ),
          images: images,
        ),
      );
    } on FormatException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message.toString()),
          backgroundColor: ColorConstants.snackBarFailedColor,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể đọc ảnh đã chọn.'),
          backgroundColor: ColorConstants.snackBarFailedColor,
        ),
      );
    }
  }

  Future<PostImageRequest> _readImage(XFile image) async {
    var extension = image.name.contains('.')
        ? image.name.split('.').last.toLowerCase()
        : '';
    if (extension == 'jpeg') extension = 'jpg';
    const contentTypes = {
      'jpg': 'image/jpeg',
      'png': 'image/png',
      'webp': 'image/webp',
      'heic': 'image/heic',
      'heif': 'image/heif',
    };
    final contentType = contentTypes[extension];
    if (contentType == null) {
      throw const FormatException(
        'Ảnh phải có định dạng JPG, PNG, WEBP, HEIC hoặc HEIF.',
      );
    }
    return PostImageRequest(
      bytes: await image.readAsBytes(),
      extension: extension,
      contentType: contentType,
    );
  }

  int? _nullableInt(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : int.parse(normalized);
  }

  String? _nullableText(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  String? _required(String? value, String label) {
    if ((value?.trim() ?? '').isEmpty) return 'Vui lòng nhập $label';
    return null;
  }

  String? _validateYear(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) return null;
    final year = int.tryParse(normalized);
    if (year == null || year < 1 || year > DateTime.now().year) {
      return 'Năm xuất bản không hợp lệ';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    final normalized = (value ?? '').trim().replaceAll(',', '.');
    final price = double.tryParse(normalized);
    if (price == null || price < 0) return 'Giá bán không hợp lệ';
    return null;
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _documentName.clear();
    _publicationYear.clear();
    _conditionNote.clear();
    _price.clear();
    _title.clear();
    _description.clear();
    setState(() {
      _category = Category.giaoTrinh;
      _condition = Condition.luot;
      _address = Address.a2;
      _images = const [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostBloc, PostState>(
      listener: (context, state) {
        if (state is PostSubmissionFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: ColorConstants.snackBarFailedColor,
            ),
          );
        }
        if (state is PostSubmissionSuccessState) {
          _clearForm();
          context.read<PostBloc>().add(const PostFormReset());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng bài thành công!'),
              backgroundColor: ColorConstants.snackBarSuccessColor,
            ),
          );
          context.go(AppRoutePaths.appHome);
        }
      },
      builder: (context, state) {
        final submitting = state is PostSubmittingState;

        return Scaffold(
          backgroundColor: ColorConstants.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Đăng tài liệu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: ColorConstants.textPrimaryColor,
                letterSpacing: -0.4,
              ),
            ),
            automaticallyImplyLeading: false,
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Section 1: Thông tin bài đăng
                  _buildFormCard(
                    title: 'Thông tin bài đăng',
                    icon: Icons.article_outlined,
                    children: [
                      TextFormField(
                        controller: _title,
                        enabled: !submitting,
                        maxLength: 255,
                        validator: (value) => _required(value, 'tiêu đề'),
                        decoration: const InputDecoration(
                          labelText: 'Tiêu đề bài đăng',
                          hintText: 'VD: Giáo trình Kinh tế vi mô 1 (NEU)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _description,
                        enabled: !submitting,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả chi tiết',
                          hintText: 'Mô tả tình trạng sách, số trang, có highlight không...',
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Address>(
                        initialValue: _address,
                        decoration: const InputDecoration(
                          labelText: 'Điểm giao dịch tại trường NEU',
                          prefixIcon: Icon(
                            Icons.place_outlined,
                            color: ColorConstants.primaryColor,
                            size: 20,
                          ),
                        ),
                        items: [
                          for (final address in Address.values)
                            DropdownMenuItem(
                              value: address,
                              child: Text(address.label),
                            ),
                        ],
                        onChanged: submitting
                            ? null
                            : (value) => setState(() => _address = value!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section 2: Thông tin tài liệu
                  _buildFormCard(
                    title: 'Thông tin tài liệu',
                    icon: Icons.menu_book_rounded,
                    children: [
                      TextFormField(
                        controller: _documentName,
                        enabled: !submitting,
                        validator: (value) => _required(value, 'tên tài liệu'),
                        decoration: const InputDecoration(
                          labelText: 'Tên tài liệu / Sách giáo trình',
                          hintText: 'VD: Kinh tế vi mô 1',
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Category>(
                        initialValue: _category,
                        decoration: const InputDecoration(
                          labelText: 'Danh mục tài liệu',
                          prefixIcon: Icon(
                            Icons.category_outlined,
                            color: ColorConstants.primaryColor,
                            size: 20,
                          ),
                        ),
                        items: [
                          for (final category in Category.values)
                            DropdownMenuItem(
                              value: category,
                              child: Text(category.label),
                            ),
                        ],
                        onChanged: submitting
                            ? null
                            : (value) => setState(() => _category = value!),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Condition>(
                        initialValue: _condition,
                        decoration: const InputDecoration(
                          labelText: 'Tình trạng tài liệu',
                          prefixIcon: Icon(
                            Icons.verified_outlined,
                            color: ColorConstants.primaryColor,
                            size: 20,
                          ),
                        ),
                        items: [
                          for (final condition in Condition.values)
                            DropdownMenuItem(
                              value: condition,
                              child: Text(condition.label),
                            ),
                        ],
                        onChanged: submitting
                            ? null
                            : (value) => setState(() => _condition = value!),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _publicationYear,
                        enabled: !submitting,
                        validator: _validateYear,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Năm xuất bản (không bắt buộc)',
                          hintText: 'VD: 2023',
                          prefixIcon: Icon(
                            Icons.calendar_today_outlined,
                            color: ColorConstants.primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _conditionNote,
                        enabled: !submitting,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Ghi chú tình trạng',
                          hintText: 'VD: Sách còn 90%, không rách, có ghi chú bút chì',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _price,
                        enabled: !submitting,
                        validator: _validatePrice,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Giá bán (VNĐ)',
                          hintText: 'VD: 35000',
                          prefixIcon: Icon(
                            Icons.attach_money_rounded,
                            color: ColorConstants.primaryColor,
                            size: 20,
                          ),
                          suffixText: 'đ',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section 3: Hình ảnh tài liệu
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ColorConstants.borderLightColor),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x060F172A),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: PostImagePicker(
                      images: _images,
                      enabled: !submitting,
                      maxImages: maxPostImages,
                      onChanged: (images) => setState(() => _images = images),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Submit button
                  Container(
                    decoration: BoxDecoration(
                      gradient: ColorConstants.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: ColorConstants.primaryColor.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: submitting ? null : _submit,
                      icon: submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.publish_rounded, size: 20),
                      label: Text(submitting ? 'Đang đăng bài...' : 'Đăng bài ngay'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorConstants.borderLightColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
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
                child: Icon(
                  icon,
                  size: 18,
                  color: ColorConstants.primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ColorConstants.textPrimaryColor,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}
