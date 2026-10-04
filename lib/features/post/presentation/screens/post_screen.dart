import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neu_trade/core/router/route_paths.dart';

import '../../domain/entities/address.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/condition.dart';
import '../../domain/entities/create_post_request.dart';
import '../bloc/post_bloc.dart';
import '../bloc/post_event.dart';
import '../bloc/post_state.dart';
import '../widgets/post_image_picker.dart';

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
        const SnackBar(content: Text('Vui lòng chọn ít nhất một ảnh.')),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message.toString())));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể đọc ảnh đã chọn.')),
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is PostSubmissionSuccessState) {
          _clearForm();
          context.read<PostBloc>().add(const PostFormReset());
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đăng bài thành công.')));
          context.go(AppRoutePaths.appHome);
        }
      },
      builder: (context, state) {
        final submitting = state is PostSubmittingState;
        return Scaffold(
          appBar: AppBar(title: const Text('Đăng tài liệu')),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const _SectionTitle('Thông tin bài đăng'),
                  TextFormField(
                    controller: _title,
                    enabled: !submitting,
                    maxLength: 255,
                    validator: (value) => _required(value, 'tiêu đề'),
                    decoration: InputDecoration(
                      labelText: 'Tiêu đề',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _description,
                    enabled: !submitting,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Mô tả',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Address>(
                    initialValue: _address,
                    decoration: InputDecoration(
                      labelText: 'Địa điểm giao dịch',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
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
                  const SizedBox(height: 32),
                  const _SectionTitle('Thông tin tài liệu'),
                  TextFormField(
                    controller: _documentName,
                    enabled: !submitting,
                    validator: (value) => _required(value, 'tên tài liệu'),
                    decoration: InputDecoration(
                      labelText: 'Tên tài liệu',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Category>(
                    initialValue: _category,
                    decoration: InputDecoration(
                      labelText: 'Danh mục',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
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
                    decoration: InputDecoration(
                      labelText: 'Tình trạng',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
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
                    decoration: InputDecoration(
                      labelText: 'Năm xuất bản (không bắt buộc)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _conditionNote,
                    enabled: !submitting,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Ghi chú tình trạng',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                    decoration: InputDecoration(
                      labelText: 'Giá bán',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  PostImagePicker(
                    images: _images,
                    enabled: !submitting,
                    maxImages: maxPostImages,
                    onChanged: (images) => setState(() => _images =  images),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
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
                        : const Icon(Icons.publish_outlined),
                    label: Text(submitting ? 'Đang đăng...' : 'Đăng bài'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    ),
  );
}
