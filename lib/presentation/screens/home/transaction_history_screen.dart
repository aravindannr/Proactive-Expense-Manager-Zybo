import 'package:flutter/material.dart';
import 'package:proactive_expense_manager/presentation/widgets/transaction_card.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data for UI display
    final transactions = [
      {'title': 'Grocery Store', 'category': 'Food', 'date': '12th Dec 2026', 'amount': '36,345', 'isExpense': true},
      {'title': 'Electricity Bill', 'category': 'Bills', 'date': '12th Dec 2026', 'amount': '379', 'isExpense': false},
      {'title': 'Electricity Bill', 'category': 'Bills', 'date': '12th Dec 2026', 'amount': '379', 'isExpense': false},
      {'title': 'Grocery Store', 'category': 'Food', 'date': '12th Dec 2026', 'amount': '36,345', 'isExpense': true},
      {'title': 'Grocery Store', 'category': 'Food', 'date': '12th Dec 2026', 'amount': '36,345', 'isExpense': true},
      {'title': 'Fruits', 'category': 'Food', 'date': '12th Dec 2026', 'amount': '379', 'isExpense': false},
      {'title': 'Grocery Store', 'category': 'Food', 'date': '12th Dec 2026', 'amount': '36,345', 'isExpense': true},
      {'title': 'Grocery Store', 'category': 'Food', 'date': '12th Dec 2026', 'amount': '379', 'isExpense': false},
      {'title': 'Water Bill', 'category': 'Bills', 'date': '12th Dec 2026', 'amount': '36,345', 'isExpense': true},
      {'title': 'Fruits', 'category': 'Food', 'date': '12th Dec 2026', 'amount': '379', 'isExpense': false},
      {'title': 'Water Bill', 'category': 'Bills', 'date': '12th Dec 2026', 'amount': '36,345', 'isExpense': true},
      {'title': 'Grocery Store', 'category': 'Food', 'date': '12th Dec 2026', 'amount': '379', 'isExpense': false},
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Text(
                'Transactions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final t = transactions[index];
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
            ),
          ],
        ),
      ),
    );
  }
}
