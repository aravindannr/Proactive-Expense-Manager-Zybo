import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:proactive_expense_manager/data/models/transaction_model.dart';
import 'package:proactive_expense_manager/presentation/bloc/category/category_bloc.dart';
import 'package:proactive_expense_manager/presentation/bloc/category/category_event.dart';
import 'package:proactive_expense_manager/presentation/bloc/category/category_state.dart';
import 'package:proactive_expense_manager/presentation/bloc/transaction/transaction_bloc.dart';
import 'package:proactive_expense_manager/presentation/bloc/transaction/transaction_event.dart';
import 'package:proactive_expense_manager/presentation/bloc/transaction/transaction_state.dart';
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
  int _alertLimit = 1000;

  @override
  void initState() {
    super.initState();
    _loadAlertLimit();
    // Ensure data is loaded
    final txState = context.read<TransactionBloc>().state;
    if (txState is TransactionInitial) {
      context.read<TransactionBloc>().add(const LoadTransactions());
    }
    final catState = context.read<CategoryBloc>().state;
    if (catState is CategoryInitial) {
      context.read<CategoryBloc>().add(const LoadCategories());
    }
  }

  Future<void> _loadAlertLimit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _alertLimit = prefs.getInt('alert_limit') ?? 1000;
    });
  }

  void _showAddTransaction() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<TransactionBloc>()),
          BlocProvider.value(value: context.read<CategoryBloc>()),
        ],
        child: const AddTransactionScreen(),
      ),
    );
  }

  String _formatAmount(double amount) {
    final intPart = amount.toInt();
    final str = intPart.toString();
    if (str.length <= 3) return str;
    final result = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      result.write(str[i]);
      count++;
      if (count == 3 && i > 0) {
        result.write(',');
      } else if (count > 3 && (count - 3) % 2 == 0 && i > 0) {
        result.write(',');
      }
    }
    return result.toString().split('').reversed.join();
  }

  String _formatDate(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final day = dt.day;
      final suffix = (day == 1 || day == 21 || day == 31)
          ? 'st'
          : (day == 2 || day == 22)
              ? 'nd'
              : (day == 3 || day == 23)
                  ? 'rd'
                  : 'th';
      return '$day$suffix ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return timestamp;
    }
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
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return _buildShimmerDashboard();
        }

        final totalIncome = state is TransactionLoaded ? state.totalIncome : 0.0;
        final totalExpense = state is TransactionLoaded ? state.totalExpense : 0.0;
        final recentTransactions =
            state is TransactionLoaded ? state.recentTransactions : <TransactionModel>[];

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
              Row(
                children: [
                  SummaryCard(
                    title: 'Total Income',
                    amount: '\u{20B9}${_formatAmount(totalIncome)}',
                    color: const Color(0xFF4CAF50),
                    icon: Icons.arrow_downward,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F8300), Color(0xFF031C00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SummaryCard(
                    title: 'Total Expense',
                    amount: '\u{20B9}${_formatAmount(totalExpense)}',
                    color: const Color(0xFFFF4444),
                    icon: Icons.arrow_upward,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB50303), Color(0xFF250000)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Monthly limit section
              _buildMonthlyLimit(totalExpense),

              const SizedBox(height: 24),

              // Recent transactions header
              const Text(
                'Recent Transactions',
                style: AppTextStyles.transactionTitle,
              ),

              const SizedBox(height: 14),

              // Transaction list
              if (recentTransactions.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'No transactions yet.\nTap + to add one!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTransactions.length,
                  itemBuilder: (context, index) {
                    final t = recentTransactions[index];
                    return TransactionCard(
                      title: t.note.isNotEmpty ? t.note : 'Transaction',
                      category: t.categoryName ?? 'Uncategorized',
                      date: _formatDate(t.timestamp),
                      amount: _formatAmount(t.amount),
                      isExpense: t.isExpense,
                      onDelete: () {
                        context
                            .read<TransactionBloc>()
                            .add(DeleteTransaction(t.id));
                      },
                    );
                  },
                ),

              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthlyLimit(double totalExpense) {
    final limit = _alertLimit.toDouble();
    final progress = limit > 0 ? (totalExpense / limit).clamp(0.0, 1.0) : 0.0;
    final remaining = limit > 0
        ? (((limit - totalExpense) / limit) * 100).clamp(0, 100).toInt()
        : 0;

    return Container(
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
            text: TextSpan(
              children: [
                TextSpan(
                  text: '\u{20B9}${_formatAmount(totalExpense)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' / \u{20B9}${_formatAmount(limit)}',
                  style: const TextStyle(
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
                    Container(
                      height: 6,
                      width: double.infinity,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    Container(
                      height: 6,
                      width: constraints.maxWidth * progress,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          colors: progress >= 1.0
                              ? [const Color(0xFFFF4444), const Color(0xFFB50303)]
                              : [const Color(0xFF7ED957), const Color(0xFF0F8300)],
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
            progress >= 1.0
                ? 'Budget exceeded!'
                : '$remaining% Remaining',
            style: TextStyle(
              color: progress >= 1.0
                  ? const Color(0xFFFF4444)
                  : Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFF2C2C2E),
        highlightColor: const Color(0xFF3A3A3C),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 200,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 160,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 14),
            ...List.generate(
              4,
              (_) => Container(
                height: 64,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
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
      heightFactor: 1.0,
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
