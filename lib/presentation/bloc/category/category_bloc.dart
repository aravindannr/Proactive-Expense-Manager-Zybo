import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:proactive_expense_manager/data/models/category_model.dart';
import 'package:proactive_expense_manager/data/repositories/category_repository.dart';
import 'package:proactive_expense_manager/presentation/bloc/category/category_event.dart';
import 'package:proactive_expense_manager/presentation/bloc/category/category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository;
  static const _uuid = Uuid();

  CategoryBloc({required this.repository}) : super(const CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    try {
      final categories = await repository.getActiveCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onAddCategory(
    AddCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      final category = CategoryModel(
        id: _uuid.v4(),
        name: event.name,
        isSynced: 0,
        isDeleted: 0,
      );
      await repository.insertCategory(category);

      // Immediately update BLoC state
      final categories = await repository.getActiveCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await repository.softDeleteCategory(event.id);

      // Immediately filter from BLoC state
      final categories = await repository.getActiveCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
