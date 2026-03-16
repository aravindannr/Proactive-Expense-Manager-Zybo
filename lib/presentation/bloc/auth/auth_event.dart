import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthSendOtp extends AuthEvent {
  final String phone;

  const AuthSendOtp(this.phone);

  @override
  List<Object?> get props => [phone];
}

class AuthVerifyOtp extends AuthEvent {
  final String otp;

  const AuthVerifyOtp(this.otp);

  @override
  List<Object?> get props => [otp];
}

class AuthCreateAccount extends AuthEvent {
  final String phone;
  final String nickname;

  const AuthCreateAccount({required this.phone, required this.nickname});

  @override
  List<Object?> get props => [phone, nickname];
}

class AuthCheckSession extends AuthEvent {
  const AuthCheckSession();
}

class AuthLogout extends AuthEvent {
  const AuthLogout();
}
