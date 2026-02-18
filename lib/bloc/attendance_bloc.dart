import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/attendance_service.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceService service;

  AttendanceBloc(this.service) : super(const AttendanceState()) {
    on<QRScanned>(_onQRScanned);
    on<DayChanged>(_onDayChanged);
  }

  void _onDayChanged(DayChanged event, Emitter<AttendanceState> emit) {
    emit(state.copyWith(selectedDay: event.day));
  }

  Future<void> _onQRScanned(
      QRScanned event,
      Emitter<AttendanceState> emit,
      ) async {
    if(!state.isScanningEnable){
      return;
    }
    emit(state.copyWith(isScanningEnable: false,isLoading: true, errorMessage: null));


    try {
      await service.markAttendance(
        studentNumber: event.studentNumber,
        day: state.selectedDay,
      );

      emit(state.copyWith(
        isLoading: false,
        success: true,
        isScanningEnable: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        isScanningEnable: true,
      ));
    }
  }
}
