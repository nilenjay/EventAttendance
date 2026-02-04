import 'package:equatable/equatable.dart';

abstract class AttendanceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceSuccess extends AttendanceState {}

class AttendanceFailure extends AttendanceState {
  final String message;

  AttendanceFailure(this.message);

  @override
  List<Object?> get props => [message];
}
