import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]) : super();

  @override
  List<Object?> get props => [];
}

class ServerFailure extends Failure {
  final String message;

  const ServerFailure({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() {
    return message;
  }
}

class CacheFailure extends Failure {
  final String message;

  const CacheFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  final String message;

  const NetworkFailure({required this.message});

  @override
  String toString() {
    return message;
  }
}

class BLEDeviceFailure extends Failure {
  final String message;

  const BLEDeviceFailure({required this.message});

  @override
  String toString() {
    return message;
  }

  @override
  List<Object?> get props => [message];
}

class AirLinkFailure extends Failure {
  final String message;

  const AirLinkFailure({required this.message});

  @override
  String toString() {
    return message;
  }
}

class StorageFailure extends Failure {
  final String message;

  const StorageFailure({required this.message});

  @override
  String toString() {
    return message;
  }
}