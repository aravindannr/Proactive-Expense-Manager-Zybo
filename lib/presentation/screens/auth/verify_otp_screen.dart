import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proactive_expense_manager/presentation/bloc/auth/auth_bloc.dart';
import 'package:proactive_expense_manager/presentation/bloc/auth/auth_event.dart';
import 'package:proactive_expense_manager/presentation/bloc/auth/auth_state.dart';
import 'package:proactive_expense_manager/presentation/bloc/category/category_bloc.dart';
import 'package:proactive_expense_manager/presentation/bloc/category/category_event.dart';
import 'package:proactive_expense_manager/presentation/bloc/transaction/transaction_bloc.dart';
import 'package:proactive_expense_manager/presentation/bloc/transaction/transaction_event.dart';
import 'package:proactive_expense_manager/presentation/screens/auth/nickname_screen.dart';
import 'package:proactive_expense_manager/presentation/screens/home/home_screen.dart';
import 'package:proactive_expense_manager/presentation/theme/app_text_styles.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String phoneNumber;

  const VerifyOtpScreen({super.key, required this.phoneNumber});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendSeconds = 32;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendSeconds = 32;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() {
          _resendSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String get _maskedPhone {
    final phone = widget.phoneNumber;
    if (phone.length >= 4) {
      final last2 = phone.substring(phone.length - 2);
      final first4 = phone.substring(0, phone.length >= 4 ? 4 : phone.length);
      return '$first4****$last2';
    }
    return phone;
  }

  void _onVerify() {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 6) return;

    context.read<AuthBloc>().add(AuthVerifyOtp(otp));
  }

  void _onResendOtp() {
    if (_resendSeconds > 0) return;
    _startResendTimer();
    context.read<AuthBloc>().add(AuthSendOtp(widget.phoneNumber));
  }

  void _onChangeNumber() {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Existing user — go straight to Home
          context.read<TransactionBloc>().add(const LoadTransactions());
          context.read<CategoryBloc>().add(const LoadCategories());
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => HomeScreen(nickname: state.nickname),
            ),
            (route) => false,
          );
        } else if (state is AuthNeedsNickname) {
          // New user — needs nickname
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NicknameScreen(phoneNumber: widget.phoneNumber),
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
                const SizedBox(height: 12),

                // Back button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                const Text(
                  'Verify OTP',
                  style: AppTextStyles.getStartedTitle,
                ),

                const SizedBox(height: 8),

                // Subtitle with masked phone
                Text(
                  'Enter the 6-Digit code sent to $_maskedPhone',
                  style: AppTextStyles.loginSubtitle.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),

                const SizedBox(height: 4),

                // Change Number link
                GestureDetector(
                  onTap: _onChangeNumber,
                  child: const Text(
                    'Change Number',
                    style: AppTextStyles.changeNumber,
                  ),
                ),

                const SizedBox(height: 12),

                // Display OTP for testing (as per PDF requirement)
                BlocBuilder<AuthBloc, AuthState>(
                  buildWhen: (prev, curr) => curr is AuthOtpSent,
                  builder: (context, state) {
                    if (state is AuthOtpSent) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.white.withValues(alpha: 0.5),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'OTP: ${state.otp}',
                              style: const TextStyle(
                                color: Color(0xFF4CAF50),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                const SizedBox(height: 16),

                // OTP input boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 48,
                      height: 52,
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: const Color(0xFF1C1C1E),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppTextStyles.primaryButtonColor,
                              width: 1,
                            ),
                          ),
                          hintText: '-',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 20,
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // Verify button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onVerify,
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
                                'Verify',
                                style: AppTextStyles.buttonText,
                              ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Resend OTP timer
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: _resendSeconds == 0 ? _onResendOtp : null,
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.resendOtp.copyWith(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        children: [
                          const TextSpan(text: 'Resend OTP in  '),
                          TextSpan(
                            text: _resendSeconds > 0 ? '${_resendSeconds}s' : '',
                            style: TextStyle(
                              color: _resendSeconds > 0
                                  ? Colors.white.withValues(alpha: 0.4)
                                  : AppTextStyles.primaryButtonColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_resendSeconds == 0)
                            const TextSpan(
                              text: 'Resend',
                              style: TextStyle(
                                color: AppTextStyles.primaryButtonColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
