import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void showManualEntrySheet(BuildContext context) {
      final controller = TextEditingController();

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (sheetContext) {
          return BlocBuilder<AttendanceBloc, AttendanceState>(
            bloc: context.read<AttendanceBloc>(),
            builder: (_, state) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 20,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Enter Student Number",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "e.g. 2410010",
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.isScanningEnable
                            ? () {
                          final studentNumber = controller.text.trim();

                          if (studentNumber.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter a student number."),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          if (!RegExp(r'^\d+$').hasMatch(studentNumber)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Student number must contain digits only."),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          Navigator.pop(sheetContext);
                          context.read<AttendanceBloc>().add(QRScanned(studentNumber));
                        }
                            : null,
                        child: const Text("Submit"),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Attendance"),
      ),
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listenWhen: (previous, current) =>
        (!previous.success && current.success) ||
            (previous.errorMessage == null && current.errorMessage != null),
        listener: (context, state) {
          if (state.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Attendance marked ✅"),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<int>(
                  initialValue: state.selectedDay,
                  decoration: const InputDecoration(
                    labelText: "Select Day",
                    border: OutlineInputBorder(),
                  ),

                  items: const [
                    DropdownMenuItem(value: 1, child: Text("Day 1")),
                    DropdownMenuItem(value: 2, child: Text("Day 2")),
                    DropdownMenuItem(value: 3, child: Text("Day 3")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      context.read<AttendanceBloc>().add(DayChanged(value));
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  icon: const Icon(Icons.keyboard),
                  label: const Text("Enter Student Number Manually"),
                  onPressed: () => showManualEntrySheet(context),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : MobileScanner(
                  onDetect: state.isScanningEnable
                      ? (barcodeCapture) {
                    if (barcodeCapture.barcodes.isEmpty) return;

                    final code = barcodeCapture.barcodes.first.rawValue;
                    if (code != null && code.isNotEmpty) {
                      debugPrint("📷 QR Scanned: $code");
                      context.read<AttendanceBloc>().add(QRScanned(code));
                    }
                  }
                      : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}