import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import 'package:neu_trade/core/router/route_paths.dart';
import 'package:neu_trade/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:neu_trade/features/auth/presentation/bloc/auth_event.dart';
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
    _studentId = TextEditingController(
      text: widget.initialEmail.length >= 8
          ? widget.initialEmail.substring(0, 8)
          : widget.initialEmail,
    );
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
        isCompleted: true,
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
            if (profile.isCompleted) {
              context.read<AuthBloc>().add(const AuthProfileCompletedEvent());
              context.go(AppRoutePaths.appHome);
              return;
            }
            _studentId.text = profile.studentId;
            _fullName.text = profile.fullName;
            _email.text = profile.email;
            _phone.text = profile.phone;
          }
        }
        if (state is ProfileSaveSuccessState) {
          context.read<AuthBloc>().add(const AuthProfileCompletedEvent());
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
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Thiết lập thông tin sinh viên',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ColorConstants.textPrimaryColor,
            letterSpacing: -0.4,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: ColorConstants.primaryColor,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                gradient: ColorConstants.primaryGradient,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: ColorConstants.primaryColor
                                        .withValues(alpha: 0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.badge_outlined,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Hoàn thiện hồ sơ sinh viên',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: ColorConstants.textPrimaryColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Thông tin này giúp xác thực thành viên chính thức thuộc ĐH Kinh tế Quốc dân (NEU).',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: ColorConstants.textSecondaryColor,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Form Card
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: ColorConstants.borderLightColor,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x060F172A),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Mã sinh viên',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: ColorConstants.textPrimaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _studentId,
                                  enabled: !isSaving,
                                  validator: ProfileValidators.studentId,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  decoration: const InputDecoration(
                                    hintText: 'VD: 11210000',
                                    prefixIcon: Icon(
                                      Icons.school_outlined,
                                      color: ColorConstants.primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),

                                const Text(
                                  'Họ và tên',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: ColorConstants.textPrimaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _fullName,
                                  enabled: !isSaving,
                                  validator: ProfileValidators.fullName,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                    hintText: 'VD: Nguyễn Văn A',
                                    prefixIcon: Icon(
                                      Icons.person_outline_rounded,
                                      color: ColorConstants.primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),

                                const Text(
                                  'Email sinh viên (@st.neu.edu.vn)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: ColorConstants.textPrimaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _email,
                                  enabled: !isSaving,
                                  validator: ProfileValidators.neuEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  autocorrect: false,
                                  decoration: const InputDecoration(
                                    hintText: 'mssv@st.neu.edu.vn',
                                    prefixIcon: Icon(
                                      Icons.alternate_email_rounded,
                                      color: ColorConstants.primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),

                                const Text(
                                  'Số điện thoại liên hệ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: ColorConstants.textPrimaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
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
                                  decoration: const InputDecoration(
                                    hintText: '09xxxxxxxx',
                                    prefixIcon: Icon(
                                      Icons.phone_outlined,
                                      color: ColorConstants.primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 26),

                                Container(
                                  decoration: BoxDecoration(
                                    gradient: ColorConstants.primaryGradient,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ColorConstants.primaryColor
                                            .withValues(alpha: 0.35),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: isSaving ? null : _saveProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size.fromHeight(50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
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
                                        : const Text(
                                            'Lưu và tiếp tục',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
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
