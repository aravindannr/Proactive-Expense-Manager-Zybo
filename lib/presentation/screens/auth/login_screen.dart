import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proactive_expense_manager/presentation/bloc/auth/auth_bloc.dart';
import 'package:proactive_expense_manager/presentation/bloc/auth/auth_event.dart';
import 'package:proactive_expense_manager/presentation/bloc/auth/auth_state.dart';
import 'package:proactive_expense_manager/presentation/screens/auth/verify_otp_screen.dart';
import 'package:proactive_expense_manager/presentation/theme/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onContinue() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) return;

    context.read<AuthBloc>().add(AuthSendOtp(phone));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VerifyOtpScreen(phoneNumber: _phoneController.text.trim()),
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Title
                const Text(
                  'Get Started',
                  style: AppTextStyles.getStartedTitle,
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Log In Using Phone & OTP',
                  style: AppTextStyles.loginSubtitle.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),

                const SizedBox(height: 32),

                // Phone input field
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Country code
                      const Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Text(
                          '+91',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      // Divider
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Container(
                          width: 1,
                          height: 24,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),

                      // Phone input
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Phone',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Continue button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTextStyles.primaryButtonColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppTextStyles.primaryButtonColor.withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Continue',
                                style: AppTextStyles.buttonText,
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
