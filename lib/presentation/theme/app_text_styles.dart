import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Inter';

  // Primary button color
  static const Color primaryButtonColor = Color(0xFF312ECB);

  // Walkthrough title
  static const walkthroughTitle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 24,
    height: 1.5,
    letterSpacing: -0.06,
    color: Colors.white,
  );

  // Walkthrough subtitle
  static const walkthroughSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 15,
    height: 1.6,
    letterSpacing: -0.04,
  );

  // Button text
  static const buttonText = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    letterSpacing: -0.03,
  );

  // Get Started title
  static const getStartedTitle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 24,
    height: 1.5,
    letterSpacing: -0.05,
    color: Colors.white,
  );

  // Login subtitle / phone & OTP text
  static const loginSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 15,
    height: 1.6,
    letterSpacing: -0.04,
  );

  // Change Number link
  static const changeNumber = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 15,
    letterSpacing: -0.04,
    color: Color(0xFF007AFF),
  );

  // Resend OTP text
  static const resendOtp = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: -0.03,
  );

  // "What should we call you" title
  static const whatShouldCallYou = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 24,
    height: 1.5,
    letterSpacing: -0.05,
    color: Colors.white,
  );

  // Total Income / Total Expense label
  static const summaryCardTitle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 13,
    height: 1.5,
    letterSpacing: -0.05,
  );

  // Amount text (summary cards)
  static const amountText = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 24,
    height: 1.5,
    letterSpacing: -0.05,
    color: Colors.white,
  );

  // Recent transaction title
  static const transactionTitle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.5,
    letterSpacing: -0.05,
    color: Colors.white,
  );

  // Recent transaction subtitle
  static const transactionSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.5,
    letterSpacing: -0.05,
  );
}
