import 'package:flutter/material.dart';
import 'package:proactive_expense_manager/presentation/screens/home/add_transaction_screen.dart';
import 'package:proactive_expense_manager/presentation/screens/home/profile_settings_screen.dart';
import 'package:proactive_expense_manager/presentation/screens/home/transaction_history_screen.dart';
import 'package:proactive_expense_manager/presentation/theme/app_text_styles.dart';
import 'package:proactive_expense_manager/presentation/widgets/summary_card.dart';
import 'package:proactive_expense_manager/presentation/widgets/transaction_card.dart';

class HomeScreen extends StatefulWidget {
  final String nickname;

  const HomeScreen({super.key, required this.nickname});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  // Sample data for UI display
  final List<Map<String, dynamic>> _recentTransactions = const [
    {'title': 'Grocery Store', 'category': 'Food', 'date': '12th Dec 2026', 'amount': '36,345', 'isExpense': true},
    {'title': 'Electricity Bill', 'category': 'Bills', 'date': '12th Dec 2026', 'amount': '379', 'isExpense': false},
    {'title': 'Grocery Store', 'category': 'Food', 'date': '12th Dec 2026', 'amount': '36,345', 'isExpense': true},
    {'title': 'Fruits', 'category': 'Food', 'date': '12th Dec 2026', 'amount': '379', 'isExpense': false},
    {'title': 'Water Bill', 'category': 'Bills', 'date': '12th Dec 2026', 'amount': '36,345', 'isExpense': true},
    {'title': 'Grocery Store', 'category': 'Food', 'date': '12th Dec 2026', 'amount': '379', 'isExpense': false},
  ];

  void _showAddTransaction() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTransactionScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: IndexedStack(
          index: _currentNavIndex,
          children: [
            _buildDashboard(),
            const TransactionHistoryScreen(),
            const ProfileSettingsScreen(),
          ],
        ),
      ),
      floatingActionButton: _currentNavIndex == 0
          ? FloatingActionButton(
              onPressed: _showAddTransaction,
              backgroundColor: const Color(0xFF4CAF50),
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            )
          : null,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Greeting
          Text(
            '\u{1F44B} Welcome, ${widget.nickname}!',
            style: AppTextStyles.getStartedTitle.copyWith(fontSize: 20),
          ),

          const SizedBox(height: 20),

          // Summary cards
          const Row(
            children: [
              SummaryCard(
                title: 'Total Income',
                amount: '\u{20B9}90,000',
                color: Color(0xFF4CAF50),
                icon: Icons.arrow_downward,
                gradient: LinearGradient(
                  colors: [Color(0xFF0F8300), Color(0xFF031C00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              SizedBox(width: 12),
              SummaryCard(
                title: 'Total Expense',
                amount: '\u{20B9}36,345',
                color: Color(0xFFFF4444),
                icon: Icons.arrow_upward,
                gradient: LinearGradient(
                  colors: [Color(0xFFB50303), Color(0xFF250000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Monthly limit section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MONTHLY LIMIT',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),

                const SizedBox(height: 10),

                // Amount row
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: '\u{20B9}7,324',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' / \u{20B9}10,000',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Progress bar with gradient
                LayoutBuilder(
                  builder: (context, constraints) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: [
                          // Background track
                          Container(
                            height: 6,
                            width: double.infinity,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          // Gradient fill
                          Container(
                            height: 6,
                            width: constraints.maxWidth * 0.73,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF7ED957),
                                  Color(0xFF0F8300),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 8),

                Text(
                  '27% Remaining',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Recent transactions header
          const Text(
            'Recent Transactions',
            style: AppTextStyles.transactionTitle,
          ),

          const SizedBox(height: 14),

          // Transaction list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentTransactions.length,
            itemBuilder: (context, index) {
              final t = _recentTransactions[index];
              return TransactionCard(
                title: t['title'] as String,
                category: t['category'] as String,
                date: t['date'] as String,
                amount: t['amount'] as String,
                isExpense: t['isExpense'] as bool,
                onDelete: () {
                  // TODO: Handle delete
                },
              );
            },
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  static const List<String> _navIcons = [
    'assets/images/icons/ic_home.png',
    'assets/images/icons/ic_tansaction_or_history.png',
    'assets/images/icons/ic_profile.png',
  ];

  Widget _buildBottomNav() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.55,
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            _navIcons.length,
            (index) => _buildNavItem(_navIcons[index], index),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String assetPath, int index) {
    final isSelected = _currentNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentNavIndex = index),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? AppTextStyles.primaryButtonColor
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Image.asset(
            assetPath,
            width: 24,
            height: 24,
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
