import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proactive_expense_manager/presentation/bloc/auth/auth_bloc.dart';
import 'package:proactive_expense_manager/presentation/bloc/auth/auth_event.dart';
import 'package:proactive_expense_manager/presentation/bloc/auth/auth_state.dart';
import 'package:proactive_expense_manager/presentation/bloc/category/category_bloc.dart';
import 'package:proactive_expense_manager/presentation/bloc/category/category_event.dart';
import 'package:proactive_expense_manager/presentation/bloc/transaction/transaction_bloc.dart';
import 'package:proactive_expense_manager/presentation/bloc/transaction/transaction_event.dart';
import 'package:proactive_expense_manager/presentation/screens/home/home_screen.dart';
import 'package:proactive_expense_manager/presentation/theme/app_text_styles.dart';

class NicknameScreen extends StatefulWidget {
  final String phoneNumber;

  const NicknameScreen({super.key, required this.phoneNumber});

  @override
  State<NicknameScreen> createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _nicknameController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = _nicknameController.text.trim();
    final valid = text.isNotEmpty;
    if (valid != _isValid) {
      setState(() {
        _isValid = valid;
      });
    }
  }

  void _onContinue() {
    if (!_isValid) return;
    final nickname = _nicknameController.text.trim();
    final phone = '+91${widget.phoneNumber}';

    context.read<AuthBloc>().add(
          AuthCreateAccount(phone: phone, nickname: nickname),
        );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.read<TransactionBloc>().add(const LoadTransactions());
          context.read<CategoryBloc>().add(const LoadCategories());
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => HomeScreen(nickname: state.nickname),
            ),
            (route) => false,
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

                // Title with wave emoji
                const Text(
                  '\u{1F44B} What should we call you?',
                  style: AppTextStyles.whatShouldCallYou,
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'This name stays only on your device.',
                  style: AppTextStyles.loginSubtitle.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),

                const SizedBox(height: 28),

                // Nickname input field
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nicknameController,
                          textCapitalization: TextCapitalization.words,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Eg: Johnnnie',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),

                      // Green checkmark when valid
                      if (_isValid)
                        const Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Icon(
                            Icons.check_circle,
                            color: Color(0xFF4CAF50),
                            size: 22,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Continue button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: (_isValid && !isLoading) ? _onContinue : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTextStyles.primaryButtonColor,
                          disabledBackgroundColor:
                              AppTextStyles.primaryButtonColor.withValues(alpha: 0.4),
                          foregroundColor: Colors.white,
                          disabledForegroundColor:
                              Colors.white.withValues(alpha: 0.4),
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
