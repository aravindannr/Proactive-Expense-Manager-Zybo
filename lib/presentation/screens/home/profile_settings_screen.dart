import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proactive_expense_manager/presentation/bloc/auth/auth_bloc.dart';
import 'package:proactive_expense_manager/presentation/bloc/auth/auth_event.dart';
import 'package:proactive_expense_manager/presentation/bloc/auth/auth_state.dart';
import 'package:proactive_expense_manager/presentation/bloc/category/category_bloc.dart';
import 'package:proactive_expense_manager/presentation/bloc/category/category_event.dart';
import 'package:proactive_expense_manager/presentation/bloc/category/category_state.dart';
import 'package:proactive_expense_manager/presentation/bloc/sync/sync_bloc.dart';
import 'package:proactive_expense_manager/presentation/bloc/sync/sync_event.dart';
import 'package:proactive_expense_manager/presentation/bloc/sync/sync_state.dart';
import 'package:proactive_expense_manager/presentation/bloc/transaction/transaction_bloc.dart';
import 'package:proactive_expense_manager/presentation/bloc/transaction/transaction_event.dart';
import 'package:proactive_expense_manager/presentation/screens/auth/login_screen.dart';
import 'package:proactive_expense_manager/presentation/theme/app_text_styles.dart';
import 'package:proactive_expense_manager/presentation/widgets/confirm_bottom_sheet.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _alertLimitController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  int _currentLimit = 1000;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final nickname = prefs.getString('nickname') ?? '';
    final limit = prefs.getInt('alert_limit') ?? 1000;
    setState(() {
      _nicknameController.text = nickname;
      _currentLimit = limit;
    });
  }

  Future<void> _saveNickname() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nickname', nickname);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nickname updated'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _setAlertLimit() async {
    final value = int.tryParse(_alertLimitController.text);
    if (value != null && value > 0) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('alert_limit', value);
      setState(() {
        _currentLimit = value;
        _alertLimitController.clear();
      });
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _alertLimitController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          },
        ),
        BlocListener<SyncBloc, SyncState>(
          listener: (context, state) {
            if (state is SyncSuccess) {
              // Reload data after sync
              context.read<CategoryBloc>().add(const LoadCategories());
              context.read<TransactionBloc>().add(const LoadTransactions());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sync completed successfully!'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            } else if (state is SyncError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sync failed: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
      child: SingleChildScrollView(
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
            _buildNicknameSection(),

            const SizedBox(height: 20),

            // Section 2: Alert Limit
            _buildAlertLimitSection(),

            const SizedBox(height: 20),

            // Section 3: Categories
            _buildCategoriesSection(),

            const SizedBox(height: 20),

            // Section 4: Cloud Sync
            _buildCloudSyncSection(),

            const SizedBox(height: 24),

            // Section 5: Logout
            _buildLogoutButton(),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ─── Section 1: Nickname ─────────────────────────────────────────────

  Widget _buildNicknameSection() {
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
            color: Colors.transparent,
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: _nicknameController,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Image.asset(
                  'assets/images/icons/ic_edit_name.png',
                  width: 20,
                  height: 20,
                ),
                onPressed: _saveNickname,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Section 2: Alert Limit ──────────────────────────────────────────

  Widget _buildAlertLimitSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
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
                    controller: _alertLimitController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
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
                  onPressed: _setAlertLimit,
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
            'Current Limit: \u{20B9}${_formatAmount(_currentLimit)}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section 3: Categories ───────────────────────────────────────────

  Widget _buildCategoriesSection() {
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
            color: Colors.transparent,
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
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
                        controller: _categoryController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
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
                    onTap: () {
                      final name = _categoryController.text.trim();
                      if (name.isNotEmpty) {
                        context.read<CategoryBloc>().add(AddCategory(name));
                        _categoryController.clear();
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTextStyles.primaryButtonColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),

              // Category list from BLoC
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoaded) {
                    return Column(
                      children: List.generate(state.categories.length, (index) {
                        final cat = state.categories[index];
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
                                      cat.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      final confirmed =
                                          await showConfirmBottomSheet(
                                            context,
                                            title: 'Confirm Delete',
                                            message:
                                                'Are you sure you want to delete this item?',
                                          );
                                      if (confirmed == true &&
                                          context.mounted) {
                                        context.read<CategoryBloc>().add(
                                          DeleteCategory(cat.id),
                                        );
                                      }
                                    },
                                    child: Image.asset(
                                      'assets/images/icons/ic_delete_cat.png',
                                      width: 30,
                                      height: 30,
                                      color: const Color(0xFFFF4444),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Section 4: Cloud Sync ───────────────────────────────────────────

  Widget _buildCloudSyncSection() {
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
        BlocBuilder<SyncBloc, SyncState>(
          builder: (context, state) {
            final isSyncing = state is SyncInProgress;
            return GestureDetector(
              onTap: isSyncing
                  ? null
                  : () => context.read<SyncBloc>().add(const StartSync()),
              child: Container(
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
                          Text(
                            isSyncing ? 'Syncing...' : 'Sync To Cloud',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isSyncing
                                ? (state as SyncInProgress).stage
                                : 'Sync and update data to the backend',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (isSyncing)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    else
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
            );
          },
        ),
      ],
    );
  }

  // ─── Section 5: Logout Button ────────────────────────────────────────

  Widget _buildLogoutButton() {
    return Center(
      child: GestureDetector(
        onTap: () async {
          final confirmed = await showConfirmBottomSheet(
            context,
            title: 'Logout',
            message: 'Are you sure you want to logout?',
            confirmLabel: 'Logout',
            confirmColor: AppTextStyles.primaryButtonColor,
          );
          if (confirmed == true && mounted) {
            context.read<AuthBloc>().add(const AuthLogout());
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(14),
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
      ),
    );
  }

  String _formatAmount(int amount) {
    final str = amount.toString();
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
}
