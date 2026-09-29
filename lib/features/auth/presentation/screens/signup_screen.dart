import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import 'package:neu_trade/core/router/route_paths.dart';
import 'package:neu_trade/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:neu_trade/features/auth/presentation/bloc/auth_event.dart';
import 'package:neu_trade/features/auth/presentation/bloc/auth_state.dart';

class SignUpScreen extends StatefulWidget {
  final String returnTo;

  const SignUpScreen({super.key, this.returnTo = AppRoutePaths.appHome});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSignUpState) {
          context.go(widget.returnTo);

          _email.clear();
          _password.clear();
        }

        if (state is AuthErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 5),
              content: Text(state.message),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoadingState;

        return Scaffold(
          backgroundColor: ColorConstants.backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  Text(
                    'hey_there',
                    style: const TextStyle(
                      fontSize: 16,
                      color: ColorConstants.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'create_an_account',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'email_required';
                            }
                            if (!RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                            ).hasMatch(value)) {
                              return 'email_invalid';
                            }
                            return null;
                          },
                          controller: _email,
                          enabled: !isLoading,
                          decoration: InputDecoration(
                            hintText: 'email_hint',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 20),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'password_required';
                            }
                            if (value.length < 8) {
                              return 'password_min_length';
                            }
                            if (!RegExp(r'[A-Z]').hasMatch(value)) {
                              return 'password_uppercase';
                            }
                            if (!RegExp(r'[a-z]').hasMatch(value)) {
                              return 'password_lowercase';
                            }
                            if (!RegExp(r'[0-9]').hasMatch(value)) {
                              return 'password_number';
                            }
                            if (!RegExp(
                              r'[!@#\/$%^&*(),.?":{}|<>]',
                            ).hasMatch(value)) {
                              return 'password_special_char';
                            }
                            return null;
                          },
                          controller: _password,
                          enabled: !isLoading,
                          decoration: InputDecoration(
                            hintText: 'password_hint',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          obscureText: _obscurePassword,
                          keyboardType: TextInputType.text,
                        ),

                        const SizedBox(height: 150),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: ColorConstants.buttonColor,
                            foregroundColor: ColorConstants.buttonTextColor,
                          ),
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {

                                    context.read<AuthBloc>().add(
                                      AuthSignUpEvent(
                                        email: _email.text.trim(),
                                        password: _password.text,
                                      ),
                                    );
                                  }
                                },
                          child: isLoading
                              ? const SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: ColorConstants.buttonColor,
                                  ),
                                )
                              : Text('sign_up_button'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'or_divider',
                          style: const TextStyle(
                            color: ColorConstants.textSecondaryColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: isLoading
                        ? null
                        : () => context.go(
                            Uri(
                              path: AppRoutePaths.login,
                              queryParameters:
                                  widget.returnTo == AppRoutePaths.appHome
                                  ? null
                                  : {'from': widget.returnTo},
                            ).toString(),
                          ),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 13,
                          color: ColorConstants.textPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(text: 'have_account_prompt'),
                          TextSpan(
                            text: 'login_button',
                            style: const TextStyle(
                              color: ColorConstants.textHighlightColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
