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
import 'package:proactive_expense_manager/presentation/screens/onboarding/walkthrough_screen.dart';
import 'package:proactive_expense_manager/services/notification_service.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.read<AuthBloc>().add(const AuthCheckSession());
      }
    });
  }

  void _navigateToHome(String nickname) {
    // Load data before navigating
    context.read<TransactionBloc>().add(const LoadTransactions());
    context.read<CategoryBloc>().add(const LoadCategories());

    // Schedule daily expense reminder at 8 PM
    NotificationService().scheduleDailyReminder(hour: 20, minute: 0);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(nickname: nickname),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _navigateToHome(state.nickname);
        } else if (state is AuthUnauthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const WalkthroughScreen(),
            ),
          );
        }
      },
      child: const Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: Image(
              image: AssetImage('assets/images/onboarding/Logo.png'),
              width: 133,
              height: 104,
            ),
          ),
        ),
      ),
    );
  }
}
