import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import 'package:neu_trade/core/router/route_paths.dart';
import 'package:neu_trade/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:neu_trade/features/profile/presentation/bloc/profile_event.dart';
import 'package:neu_trade/features/profile/presentation/bloc/profile_state.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({
    super.key,
    required this.userId,
    required this.initialEmail,
  });

  final String userId;
  final String initialEmail;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _studentId;
  late final TextEditingController _fullName;
  late final TextEditingController _email;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    _studentId = TextEditingController(text: widget.initialEmail.substring(0, 8));
    _fullName = TextEditingController();
    _email = TextEditingController(text: widget.initialEmail);
    _phone = TextEditingController();
    context.read<ProfileBloc>().add(const ProfileLoadEvent());
  }

  void _saveProfile() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    context.read<ProfileBloc>().add(
      ProfileSaveEvent(
        studentId: _studentId.text.trim().toUpperCase(),
        fullName: _fullName.text.trim(),
        email: _email.text.trim().toLowerCase(),
        phone: ProfileValidators.normalizePhone(_phone.text),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ColorConstants.snackBarFailedColor,
      ),
    );
  }

  @override
  void dispose() {
    _studentId.dispose();
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoadedState) {
          final profile = state.profile;
          if (profile != null) {
            _studentId.text = profile.studentId;
            _fullName.text = profile.fullName;
            _email.text = profile.email;
            _phone.text = profile.phone;
          }
        }
        if (state is ProfileSaveSuccessState) {
          context.go(AppRoutePaths.appHome);
        }
        if (state is ProfileErrorState) {
          _showError(state.message);
        }
      },
      builder: (context, state) {
        final isLoading =
            state is ProfileInitialState || state is ProfileLoadingState;
        final isSaving =
            state is ProfileSavingState || state is ProfileSaveSuccessState;
        return _buildScaffold(isLoading: isLoading, isSaving: isSaving);
      },
    );
  }

  Widget _buildScaffold({required bool isLoading, required bool isSaving}) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Thông tin sinh viên'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.badge_outlined,
                        size: 72,
                        color: ColorConstants.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Hoàn thiện hồ sơ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Thông tin này giúp xác minh thành viên của cộng đồng NEU.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ColorConstants.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _studentId,
                        enabled: !isSaving,
                        validator: ProfileValidators.studentId,
                        textCapitalization: TextCapitalization.characters,
                        decoration: _decoration(
                          label: 'Mã sinh viên',
                          icon: Icons.school_outlined,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _fullName,
                        enabled: !isSaving,
                        validator: ProfileValidators.fullName,
                        textCapitalization: TextCapitalization.words,
                        decoration: _decoration(
                          label: 'Họ và tên',
                          icon: Icons.person_outline,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _email,
                        enabled: !isSaving,
                        validator: ProfileValidators.neuEmail,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        decoration: _decoration(
                          label: 'Email sinh viên',
                          hint: 'mssv@st.neu.edu.vn',
                          icon: Icons.alternate_email,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phone,
                        enabled: !isSaving,
                        validator: ProfileValidators.phone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9+\s.-]'),
                          ),
                        ],
                        decoration: _decoration(
                          label: 'Số điện thoại',
                          hint: '09xxxxxxxx',
                          icon: Icons.phone_outlined,
                        ),
                      ),
                      const SizedBox(height: 28),
                      FilledButton(
                        onPressed: isSaving ? null : _saveProfile,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Lưu và tiếp tục'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

// VALIDATOR
abstract final class ProfileValidators {
  ProfileValidators._();

  static String? studentId(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Vui lòng nhập mã sinh viên';
    if (!RegExp(r'^[A-Za-z0-9]{5,20}$').hasMatch(input)) {
      return 'Mã sinh viên chỉ gồm 5–20 chữ cái hoặc chữ số';
    }
    return null;
  }

  static String? fullName(String? value) {
    if ((value?.trim() ?? '').isEmpty) return 'Vui lòng nhập họ tên';
    return null;
  }

  static String? neuEmail(String? value) {
    final input = value?.trim().toLowerCase() ?? '';
    if (input.isEmpty) return 'Vui lòng nhập email';
    if (!RegExp(r'^[a-z0-9._%+-]+@st\.neu\.edu\.vn$').hasMatch(input)) {
      return 'Email phải có đuôi @st.neu.edu.vn';
    }
    return null;
  }

  static String? phone(String? value) {
    final input = (value ?? '').replaceAll(RegExp(r'[\s.-]'), '');
    if (input.isEmpty) return 'Vui lòng nhập số điện thoại';
    if (!RegExp(r'^(?:\+84|0)\d{9}$').hasMatch(input)) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  static String normalizePhone(String value) {
    return value.replaceAll(RegExp(r'[\s.-]'), '');
  }
}
