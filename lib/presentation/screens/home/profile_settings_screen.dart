import 'package:flutter/material.dart';
import 'package:proactive_expense_manager/presentation/theme/app_text_styles.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final TextEditingController _nicknameController =
      TextEditingController(text: 'Naazley');
  final TextEditingController _alertLimitController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  int _currentLimit = 1000;
  final List<String> _categories = ['Food', 'Bills', 'Transport', 'Shopping'];

  @override
  void dispose() {
    _nicknameController.dispose();
    _alertLimitController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Header
          const Text(
            'Profile & Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          // Section 1: Nickname
          _NicknameSection(controller: _nicknameController),

          const SizedBox(height: 20),

          // Section 2: Alert Limit
          _AlertLimitSection(
            controller: _alertLimitController,
            currentLimit: _currentLimit,
            onSet: () {
              final value = int.tryParse(_alertLimitController.text);
              if (value != null && value > 0) {
                setState(() {
                  _currentLimit = value;
                  _alertLimitController.clear();
                });
              }
            },
          ),

          const SizedBox(height: 20),

          // Section 3: Categories
          _CategoriesSection(
            categories: _categories,
            controller: _categoryController,
            onAdd: () {
              final name = _categoryController.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _categories.add(name);
                  _categoryController.clear();
                });
              }
            },
            onDelete: (index) {
              setState(() {
                _categories.removeAt(index);
              });
            },
          ),

          const SizedBox(height: 20),

          // Section 4: Cloud Sync
          const _CloudSyncSection(),

          const SizedBox(height: 24),

          // Section 5: Logout
          const _LogoutButton(),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ─── Section 1: Nickname ─────────────────────────────────────────────

class _NicknameSection extends StatelessWidget {
  final TextEditingController controller;

  const _NicknameSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NICKNAME',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 20,
                ),
                onPressed: () {
                  // TODO: Enable editing
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Section 2: Alert Limit ──────────────────────────────────────────

class _AlertLimitSection extends StatelessWidget {
  final TextEditingController controller;
  final int currentLimit;
  final VoidCallback onSet;

  const _AlertLimitSection({
    required this.controller,
    required this.currentLimit,
    required this.onSet,
  });

  @override
  Widget build(BuildContext context) {
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
            'ALERT LIMIT (\u{20B9})',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: InputBorder.none,
                      hintText: 'Amount  (\u{20B9})',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: onSet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTextStyles.primaryButtonColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: const Text(
                    'Set',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Current Limit: \u{20B9}${_formatAmount(currentLimit)}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(int amount) {
    final str = amount.toString();
    final result = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      result.write(str[i]);
      count++;
      if (count == 3 && i > 0) {
        result.write(',');
        count = 0;
      }
    }
    return result.toString().split('').reversed.join();
  }
}

// ─── Section 3: Categories ───────────────────────────────────────────

class _CategoriesSection extends StatelessWidget {
  final List<String> categories;
  final TextEditingController controller;
  final VoidCallback onAdd;
  final void Function(int index) onDelete;

  const _CategoriesSection({
    required this.categories,
    required this.controller,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CATEGORIES',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              // Add category row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: controller,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          border: InputBorder.none,
                          hintText: 'New category Name',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onAdd,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppTextStyles.primaryButtonColor,
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.add, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),

              // Category list
              ...List.generate(categories.length, (index) {
                return Column(
                  children: [
                    const SizedBox(height: 4),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.08),
                      height: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              categories[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => onDelete(index),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFFF4444),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.asset(
                                'assets/images/icons/ic_delete.png',
                                width: 18,
                                height: 18,
                                color: const Color(0xFFFF4444),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Section 4: Cloud Sync ───────────────────────────────────────────

class _CloudSyncSection extends StatelessWidget {
  const _CloudSyncSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CLOUD SYNC',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTextStyles.primaryButtonColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sync To Cloud',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sync and update data to the backend',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Image.asset(
                'assets/images/icons/ic_cloud.png',
                width: 28,
                height: 28,
                color: Colors.white.withValues(alpha: 0.9),
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Section 5: Logout Button ────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          // TODO: Implement logout
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Log Out',
              style: TextStyle(
                color: Colors.redAccent.withValues(alpha: 0.9),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Image.asset(
              'assets/images/icons/ic_logout.png',
              width: 18,
              height: 18,
              color: Colors.redAccent.withValues(alpha: 0.9),
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
