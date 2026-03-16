import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:proactive_expense_manager/presentation/bloc/transaction/transaction_bloc.dart';
import 'package:proactive_expense_manager/presentation/bloc/transaction/transaction_event.dart';
import 'package:proactive_expense_manager/presentation/bloc/transaction/transaction_state.dart';
import 'package:proactive_expense_manager/presentation/theme/app_text_styles.dart';
import 'package:proactive_expense_manager/presentation/widgets/transaction_card.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Text(
            'Transactions',
            style: AppTextStyles.getStartedTitle,
          ),
        ),

        Expanded(
          child: BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              if (state is TransactionLoading) {
                return _buildShimmer();
              }

              if (state is TransactionLoaded) {
                final transactions = state.allTransactions;
                if (transactions.isEmpty) {
                  return Center(
                    child: Text(
                      'No transactions yet.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 14,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final t = transactions[index];
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
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFF2C2C2E),
        highlightColor: const Color(0xFF3A3A3C),
        child: ListView.builder(
          itemCount: 8,
          itemBuilder: (_, __) => Container(
            height: 64,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}
