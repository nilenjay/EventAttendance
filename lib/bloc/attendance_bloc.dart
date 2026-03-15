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
    if (!state.isScanningEnable) return;

    emit(state.copyWith(
      isScanningEnable: false,
      isLoading: true,
      clearError: true,   // explicitly wipe previous error
      success: false,     // reset success before new attempt
    ));

    try {
      await service.markAttendance(
        studentNumber: event.studentNumber,
        day: state.selectedDay,
      );

      // FIX 3: emit success: true, then immediately reset it
      // so the listener only fires once and won't re-trigger on future state changes
      emit(state.copyWith(
        isLoading: false,
        success: true,
        isScanningEnable: true,
      ));

      // Reset success flag right away so it doesn't linger in state
      await Future<void>.delayed(Duration.zero);
      emit(state.copyWith(success: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        isScanningEnable: true,
        success: false,
      ));

      // Reset error after a beat so it doesn't re-trigger on future rebuilds
      await Future<void>.delayed(Duration.zero);
      emit(state.copyWith(clearError: true));
    }
  }
}