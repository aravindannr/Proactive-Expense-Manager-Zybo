import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proactive_expense_manager/data/api/api_service.dart';
import 'package:proactive_expense_manager/presentation/bloc/auth/auth_event.dart';
import 'package:proactive_expense_manager/presentation/bloc/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService apiService;

  AuthBloc({required this.apiService}) : super(const AuthInitial()) {
    on<AuthCheckSession>(_onCheckSession);
    on<AuthSendOtp>(_onSendOtp);
    on<AuthVerifyOtp>(_onVerifyOtp);
    on<AuthCreateAccount>(_onCreateAccount);
    on<AuthLogout>(_onLogout);
  }

  Future<void> _onCheckSession(
    AuthCheckSession event,
    Emitter<AuthState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final nickname = prefs.getString('nickname');

    if (token != null && nickname != null) {
      apiService.setToken(token);
      emit(AuthAuthenticated(nickname: nickname, token: token));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSendOtp(
    AuthSendOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final phone = '+91${event.phone}';
      final response = await apiService.sendOtp(phone);

      if (response['status'] == 'success') {
        final userExists = response['user_exists'] as bool;
        final otp = response['otp'] as String;
        final token = response['token'] as String?;
        final nickname = response['nickname'] as String?;

        emit(AuthOtpSent(
          phone: phone,
          otp: otp,
          userExists: userExists,
          nickname: nickname,
          token: token,
        ));
      } else {
        emit(AuthError(response['message'] ?? 'Failed to send OTP'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOtp(
    AuthVerifyOtp event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthOtpSent) return;

    emit(const AuthLoading());

    if (event.otp != currentState.otp) {
      emit(const AuthError('Invalid OTP'));
      return;
    }

    try {
      if (currentState.userExists &&
          currentState.nickname != null &&
          currentState.token != null) {
        // Existing user — save and proceed to Home
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', currentState.token!);
        await prefs.setString('nickname', currentState.nickname!);
        apiService.setToken(currentState.token!);

        emit(AuthAuthenticated(
          nickname: currentState.nickname!,
          token: currentState.token!,
        ));
      } else {
        // New user — needs nickname
        emit(AuthNeedsNickname(
          phone: currentState.phone,
          token: currentState.token ?? '',
        ));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCreateAccount(
    AuthCreateAccount event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final response =
          await apiService.createAccount(event.phone, event.nickname);

      if (response['status'] == 'success') {
        final token = response['token'] as String;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('nickname', event.nickname);
        apiService.setToken(token);

        emit(AuthAuthenticated(nickname: event.nickname, token: token));
      } else {
        emit(AuthError(response['message'] ?? 'Failed to create account'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(
    AuthLogout event,
    Emitter<AuthState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('nickname');
    emit(const AuthUnauthenticated());
  }
}
