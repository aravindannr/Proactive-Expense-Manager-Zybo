import 'package:equatable/equatable.dart';

abstract class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object?> get props => [];
}

class SyncInitial extends SyncState {
  const SyncInitial();
}

class SyncInProgress extends SyncState {
  final String stage;

  const SyncInProgress(this.stage);

  @override
  List<Object?> get props => [stage];
}

class SyncSuccess extends SyncState {
  const SyncSuccess();
}

class SyncError extends SyncState {
  final String message;

  const SyncError(this.message);

  @override
  List<Object?> get props => [message];
}
