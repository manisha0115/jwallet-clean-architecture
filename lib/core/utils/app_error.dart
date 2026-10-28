import 'package:equatable/equatable.dart';

class AppError extends Equatable implements Exception{
  final AppErrorType appErrorType;
  final String? message;

  const AppError(this.appErrorType, {this.message});

  @override
  List<Object?> get props => [appErrorType, message];
}

enum AppErrorType { api, network, database, unauthorised, sessionDenied }




