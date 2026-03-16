import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proactive_expense_manager/data/api/api_service.dart';
import 'package:proactive_expense_manager/data/database/database_helper.dart';
import 'package:proactive_expense_manager/data/repositories/category_repository.dart';
import 'package:proactive_expense_manager/data/repositories/transaction_repository.dart';
import 'package:proactive_expense_manager/presentation/bloc/auth/auth_bloc.dart';
import 'package:proactive_expense_manager/presentation/bloc/category/category_bloc.dart';
import 'package:proactive_expense_manager/presentation/bloc/sync/sync_bloc.dart';
import 'package:proactive_expense_manager/presentation/bloc/transaction/transaction_bloc.dart';
import 'package:proactive_expense_manager/presentation/screens/initial_screen.dart';
import 'package:proactive_expense_manager/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final notificationService = NotificationService();
  await notificationService.initialize();

  final dbHelper = DatabaseHelper();
  final apiService = ApiService();
  final categoryRepo = CategoryRepository(dbHelper);
  final transactionRepo = TransactionRepository(dbHelper);

  runApp(MyApp(
    apiService: apiService,
    categoryRepo: categoryRepo,
    transactionRepo: transactionRepo,
    notificationService: notificationService,
  ));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;
  final CategoryRepository categoryRepo;
  final TransactionRepository transactionRepo;
  final NotificationService notificationService;

  const MyApp({
    super.key,
    required this.apiService,
    required this.categoryRepo,
    required this.transactionRepo,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(apiService: apiService),
        ),
        BlocProvider(
          create: (_) => CategoryBloc(repository: categoryRepo),
        ),
        BlocProvider(
          create: (_) => TransactionBloc(
            repository: transactionRepo,
            notificationService: notificationService,
          ),
        ),
        BlocProvider(
          create: (_) => SyncBloc(
            apiService: apiService,
            categoryRepository: categoryRepo,
            transactionRepository: transactionRepo,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Proactive Expense Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Inter',
          colorScheme:
              ColorScheme.fromSeed(seedColor: const Color(0xFF312ECB)),
          primaryColor: const Color(0xFF312ECB),
        ),
        home: const InitialScreen(),
      ),
    );
  }
}
