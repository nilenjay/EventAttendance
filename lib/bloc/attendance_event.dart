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
