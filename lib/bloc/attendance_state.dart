import 'package:equatable/equatable.dart';

class AttendanceState extends Equatable {
  final int selectedDay;
  final bool isLoading;
  final String? errorMessage;
  final bool success;
  final bool isScanningEnable;

  const AttendanceState({
    this.selectedDay = 1,
    this.isLoading = false,
    this.errorMessage,
    this.success = false,
    this.isScanningEnable=true,
  });

  AttendanceState copyWith({
    int? selectedDay,
    bool? isLoading,
    String? errorMessage,
    bool? success,
    bool? isScanningEnable,
  }) {
    return AttendanceState(
      selectedDay: selectedDay ?? this.selectedDay,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      success: success ?? false,
      isScanningEnable:
        isScanningEnable ?? this.isScanningEnable,
    );
  }

  @override
  List<Object?> get props =>[selectedDay, isLoading, errorMessage, success,isScanningEnable];
}
