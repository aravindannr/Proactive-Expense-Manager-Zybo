import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:proactive_expense_manager/presentation/screens/auth/login_screen.dart';
import 'package:proactive_expense_manager/presentation/theme/app_text_styles.dart';

class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key});

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_WalkthroughPage> _pages = [
    _WalkthroughPage(
      title: 'Privacy by Default, With Zero\nAds or Hidden Tracking',
      description: 'No ads. No trackers. No third-party analytics.',
    ),
    _WalkthroughPage(
      title: 'Insights That Help You Spend\nBetter Without Complexity',
      description: 'See category-wise spending, recent activity.',
    ),
    _WalkthroughPage(
      title: 'Local-First Tracking That\nStays Fully On Your Device',
      description: 'Your finances stay on your phone.',
    ),
  ];

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _onGetStarted();
    }
  }

  void _onBackPressed() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onGetStarted() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _onSkip() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full-screen background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/onboarding/walkthrough_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // Invisible PageView for swipe gesture handling
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return const SizedBox.expand();
            },
          ),

          // Bottom gradient + blur overlay
          _buildGradientOverlay(context),

          // Content overlay (Skip, indicator, text, button)
          SafeArea(
            child: Column(
              children: [
                // Top bar with SKIP
                _buildTopBar(),

                const Spacer(),

                // Bottom content area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page indicator bars
                      _buildPageIndicator(),
                      const SizedBox(height: 28),

                      // Title
                      Text(
                        _pages[_currentPage].title,
                        style: AppTextStyles.walkthroughTitle,
                      ),
                      const SizedBox(height: 12),

                      // Description
                      Text(
                        _pages[_currentPage].description,
                        style: AppTextStyles.walkthroughSubtitle.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Bottom navigation row
                      _buildBottomRow(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientOverlay(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: screenHeight * 0.55,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.8),
                  Colors.black,
                ],
                stops: const [0.0, 0.3, 0.65, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_currentPage < _pages.length - 1)
            GestureDetector(
              onTap: _onSkip,
              child: const Text(
                'SKIP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            )
          else
            const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      children: List.generate(
        _pages.length,
        (index) {
          final bool isActive = index <= _currentPage;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index < _pages.length - 1 ? 6 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomRow() {
    final bool isLastPage = _currentPage == _pages.length - 1;
    final bool isFirstPage = _currentPage == 0;

    final nextButton = Expanded(
      child: SizedBox(
        height: 48,
        child: ElevatedButton(
          onPressed: isLastPage ? _onGetStarted : _onNextPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTextStyles.primaryButtonColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            isLastPage ? 'Get Started' : 'Next',
            style: AppTextStyles.buttonText,
          ),
        ),
      ),
    );

    if (isFirstPage) {
      return Row(children: [nextButton]);
    }

    return Row(
      children: [
        // Back button
        GestureDetector(
          onTap: _onBackPressed,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Next / Get Started button
        nextButton,
      ],
    );
  }
}

class _WalkthroughPage {
  final String title;
  final String description;

  const _WalkthroughPage({
    required this.title,
    required this.description,
  });
}
