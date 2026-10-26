import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neu_trade/core/constants/color_constants.dart';

import '../../domain/entities/post_history_address.dart';
import '../../domain/entities/post_history_category.dart';
import '../../domain/entities/post_history_condition.dart';
import '../../domain/entities/post_history_entity.dart';
import '../../domain/entities/post_history_image_input.dart';
import '../../domain/entities/post_history_status.dart';
import '../../domain/entities/post_history_update_request.dart';
import '../bloc/post_history_edit_bloc.dart';
import '../bloc/post_history_edit_event.dart';
import '../bloc/post_history_edit_state.dart';
import '../widgets/post_history_delete_dialog.dart';
import '../widgets/post_history_form_fields.dart';
import '../widgets/post_history_image_editor.dart';

class PostHistoryEditScreen extends StatefulWidget {
  const PostHistoryEditScreen({super.key, required this.postId});

  final int postId;

  @override
  State<PostHistoryEditScreen> createState() => _PostHistoryEditScreenState();
}

class _PostHistoryEditScreenState extends State<PostHistoryEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _documentName = TextEditingController();
  final _publicationYear = TextEditingController();
  final _conditionNote = TextEditingController();
  final _price = TextEditingController();
  final _title = TextEditingController();
  final _description = TextEditingController();

  PostHistoryCategory _category = PostHistoryCategory.giaoTrinh;
  PostHistoryCondition _condition = PostHistoryCondition.luot;
  PostHistoryAddress _address = PostHistoryAddress.a2;
  List<PostHistoryImageInput> _images = const [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    final currentState = context.read<PostHistoryEditBloc>().state;
    if (currentState is PostHistoryEditReadyState) {
      _populateFromPost(currentState.initialPost);
    } else {
      context.read<PostHistoryEditBloc>().add(
        PostHistoryEditLoadRequested(widget.postId),
      );
    }
  }

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

  void _populateFromPost(PostHistoryEntity post) {
    if (_initialized) return;
    _initialized = true;
    _title.text = post.title;
    _description.text = post.description ?? '';
    _address = post.address;

    _documentName.text = post.document.name;
    _category = post.document.category;
    _condition = post.document.condition;
    _publicationYear.text = post.document.publicationYear?.toString() ?? '';
    _conditionNote.text = post.document.conditionNote ?? '';
    final priceInt = post.document.price.toInt();
    _price.text = post.document.price == priceInt
        ? '$priceInt'
        : '${post.document.price}';

    _images = post.imageUrls
        .map((url) => ExistingPostHistoryImage(url: url))
        .toList(growable: false);
  }

  Future<void> _submit(PostHistoryEntity initialPost) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng giữ hoặc chọn ít nhất 1 ảnh tài liệu.'),
          backgroundColor: ColorConstants.snackBarFailedColor,
        ),
      );
      return;
    }

    if (initialPost.status == PostHistoryStatus.dangHienThi) {
      final confirmed = await showPostHistoryReapprovalWarningDialog(context);
      if (!confirmed || !mounted) return;
    }

    context.read<PostHistoryEditBloc>().add(
      PostHistoryEditSubmitted(
        postId: initialPost.id,
        input: PostHistoryUpdateRequest(
          document: PostHistoryDocumentUpdateRequest(
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
        images: _images,
      ),
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostHistoryEditBloc, PostHistoryEditState>(
      listener: (context, state) {
        if (state is PostHistoryEditReadyState) {
          _populateFromPost(state.initialPost);
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: ColorConstants.snackBarFailedColor,
              ),
            );
          }
        }
        if (state is PostHistoryEditSuccessState) {
          Navigator.of(context).pop(state.updatedPost);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: ColorConstants.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: ColorConstants.textPrimaryColor,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: const Text(
              'Chỉnh sửa bài đăng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: ColorConstants.textPrimaryColor,
                letterSpacing: -0.4,
              ),
            ),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, PostHistoryEditState state) {
    if (state is PostHistoryEditLoadingState) {
      return const Center(
        child: CircularProgressIndicator(color: ColorConstants.primaryColor),
      );
    }

    if (state is PostHistoryEditLoadFailureState) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: ColorConstants.greyShade400,
              ),
              const SizedBox(height: 12),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: ColorConstants.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is PostHistoryEditReadyState) {
      final submitting = state.isSubmitting;
      final initialPost = state.initialPost;

      return SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (initialPost.status == PostHistoryStatus.dangHienThi) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ColorConstants.orangeShade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ColorConstants.orangeShade100),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: ColorConstants.orangeShade700,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Bài đăng đang hiển thị công khai. Sau khi lưu chỉnh sửa, bài đăng sẽ chuyển về trạng thái "Chờ duyệt" để quản trị viên duyệt lại.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: ColorConstants.orangeShade700,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              PostHistoryFormSectionCard(
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
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _description,
                    enabled: !submitting,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Mô tả chi tiết',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<PostHistoryAddress>(
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
                      for (final address in PostHistoryAddress.values)
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
              PostHistoryFormSectionCard(
                title: 'Thông tin tài liệu',
                icon: Icons.menu_book_rounded,
                children: [
                  TextFormField(
                    controller: _documentName,
                    enabled: !submitting,
                    validator: (value) => _required(value, 'tên tài liệu'),
                    decoration: const InputDecoration(
                      labelText: 'Tên tài liệu / Sách giáo trình',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<PostHistoryCategory>(
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
                      for (final category in PostHistoryCategory.values)
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
                  DropdownButtonFormField<PostHistoryCondition>(
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
                      for (final condition in PostHistoryCondition.values)
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ColorConstants.borderLightColor),
                ),
                child: PostHistoryImageEditor(
                  images: _images,
                  enabled: !submitting,
                  onChanged: (images) => setState(() => _images = images),
                ),
              ),
              const SizedBox(height: 28),
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
                  onPressed: submitting ? null : () => _submit(initialPost),
                  icon: submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined, size: 20),
                  label: Text(
                    submitting ? 'Đang lưu chỉnh sửa...' : 'Lưu chỉnh sửa',
                  ),
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
      );
    }

    return const SizedBox.shrink();
  }
}
