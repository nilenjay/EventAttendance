import 'package:flutter_bloc/flutter_bloc.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';
import '../services/attendance_service.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceService service;

  AttendanceBloc(this.service) : super(AttendanceInitial()) {
    on<QRScanned>(_onQRScanned);
  }

  Future<void> _onQRScanned(
      QRScanned event,
      Emitter<AttendanceState> emit,
      ) async {
    emit(AttendanceLoading());

    try {
      await service.markAttendance(event.studentNumber);
      emit(AttendanceSuccess());
    } catch (e) {
      emit(AttendanceFailure(e.toString()));
    }
  }
}
