import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proactive_expense_manager/presentation/bloc/category/category_bloc.dart';
import 'package:proactive_expense_manager/presentation/bloc/category/category_state.dart';
import 'package:proactive_expense_manager/presentation/bloc/transaction/transaction_bloc.dart';
import 'package:proactive_expense_manager/presentation/bloc/transaction/transaction_event.dart';
import 'package:proactive_expense_manager/presentation/theme/app_text_styles.dart';
import 'package:proactive_expense_manager/presentation/widgets/category_chip.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _isExpense = true;
  String? _selectedCategoryId;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onSave() {
    final note = _titleController.text.trim();
    final amountText = _amountController.text.trim();
    if (note.isEmpty || amountText.isEmpty || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;

    context.read<TransactionBloc>().add(AddTransaction(
          amount: amount,
          note: note,
          type: _isExpense ? 'debit' : 'credit',
          categoryId: _selectedCategoryId!,
        ));

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add Transaction',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Expense / Income toggle
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isExpense = true),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _isExpense
                            ? AppTextStyles.primaryButtonColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Expense',
                        style: TextStyle(
                          color: _isExpense
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isExpense = false),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: !_isExpense
                            ? AppTextStyles.primaryButtonColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Income',
                        style: TextStyle(
                          color: !_isExpense
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Title field
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Title',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 15,
              ),
              filled: true,
              fillColor: const Color(0xFF2C2C2E),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Amount field
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Amount (\u{20B9})',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 15,
              ),
              filled: true,
              fillColor: const Color(0xFF2C2C2E),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Category label
          Text(
            'CATEGORY',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 10),

          // Category chips from BLoC
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              if (state is CategoryLoaded && state.categories.isNotEmpty) {
                // Auto-select first if none selected
                if (_selectedCategoryId == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _selectedCategoryId == null) {
                      setState(() {
                        _selectedCategoryId = state.categories.first.id;
                      });
                    }
                  });
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: state.categories.map((cat) {
                    return CategoryChip(
                      label: cat.name,
                      isSelected: _selectedCategoryId == cat.id,
                      onTap: () => setState(() => _selectedCategoryId = cat.id),
                    );
                  }).toList(),
                );
              }
              return Text(
                'No categories. Add from Profile settings.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 13,
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Info text
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.white.withValues(alpha: 0.4),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Everything you add here is saved only on your device.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTextStyles.primaryButtonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Save',
                style: AppTextStyles.buttonText,
              ),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
