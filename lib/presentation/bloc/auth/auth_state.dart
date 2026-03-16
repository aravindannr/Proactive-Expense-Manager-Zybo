import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthOtpSent extends AuthState {
  final String phone;
  final String otp;
  final bool userExists;
  final String? nickname;
  final String? token;

  const AuthOtpSent({
    required this.phone,
    required this.otp,
    required this.userExists,
    this.nickname,
    this.token,
  });

  @override
  List<Object?> get props => [phone, otp, userExists, nickname, token];
}

class AuthAuthenticated extends AuthState {
  final String nickname;
  final String token;

  const AuthAuthenticated({required this.nickname, required this.token});

  @override
  List<Object?> get props => [nickname, token];
}

class AuthNeedsNickname extends AuthState {
  final String phone;
  final String token;

  const AuthNeedsNickname({required this.phone, required this.token});

  @override
  List<Object?> get props => [phone, token];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}
