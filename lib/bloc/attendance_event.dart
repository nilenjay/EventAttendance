import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class QRScanned extends AttendanceEvent {
  final String studentNumber;

  QRScanned(this.studentNumber);

  @override
  List<Object?> get props => [studentNumber];
}

class DayChanged extends AttendanceEvent {
  final int day;

  DayChanged(this.day);

  @override
  // FIX 4: removed stale TODO comment
  List<Object?> get props => [day];
}