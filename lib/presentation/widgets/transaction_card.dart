import 'package:flutter/material.dart';
import 'package:proactive_expense_manager/presentation/theme/app_text_styles.dart';

class TransactionCard extends StatelessWidget {
  final String title;
  final String category;
  final String date;
  final String amount;
  final bool isExpense;
  final VoidCallback? onDelete;

  const TransactionCard({
    super.key,
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.isExpense,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final amountColor = isExpense
        ? const Color(0xFFFF4444)
        : const Color(0xFF4CAF50);
    final amountPrefix = isExpense ? '-' : '+';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Left icon
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              'assets/images/icons/ic_cart.png',
              width: 10,
              height: 10,
              color: Colors.white.withValues(alpha: 0.6),
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(width: 12),

          // Title & category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.transactionTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  category,
                  style: AppTextStyles.transactionSubtitle.copyWith(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Date & amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$amountPrefix\u{20B9}$amount',
                style: TextStyle(
                  color: amountColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(width: 8),

          // Delete icon
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFFF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Image.asset(
                'assets/images/icons/ic_delete.png',
                width: 16,
                height: 16,
                color: const Color(0xFFFF4444),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
