import 'package:equatable/equatable.dart';

class AttendanceState extends Equatable {
  final int selectedDay;
  final bool isLoading;
  final String? errorMessage;
  final bool success;

  const AttendanceState({
    this.selectedDay = 1,
    this.isLoading = false,
    this.errorMessage,
    this.success = false,
  });

  AttendanceState copyWith({
    int? selectedDay,
    bool? isLoading,
    String? errorMessage,
    bool? success,
  }) {
    return AttendanceState(
      selectedDay: selectedDay ?? this.selectedDay,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      success: success ?? false,
    );
  }

  @override
  List<Object?> get props =>[selectedDay, isLoading, errorMessage, success];
}
