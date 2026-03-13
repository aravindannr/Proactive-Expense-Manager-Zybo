import 'package:flutter/material.dart';
import 'package:proactive_expense_manager/presentation/screens/onboarding/walkthrough_screen.dart';

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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const WalkthroughScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
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
    );
  }
}
