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
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Attendance"),
      ),

      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          // ✅ Success
          if (state.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Attendance marked ✅"),
                backgroundColor: Colors.green,
              ),
            );
          }

          // ❌ Error
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
                  value: state.selectedDay,
                  decoration: const InputDecoration(
                    labelText: "Select Day",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 1,
                      child: Text("Day 1"),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text("Day 2"),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      context
                          .read<AttendanceBloc>()
                          .add(DayChanged(value));
                    }
                  },
                ),
              ),

              const SizedBox(height: 12),
              Expanded(
                child: state.isLoading
                    ? const Center(
                  child: CircularProgressIndicator(),
                )
                    : MobileScanner(
                  onDetect: state.isScanningEnable?(barcodeCapture) {
                    final code = barcodeCapture.barcodes.first.rawValue;

                    if (code != null) {
                      debugPrint("📷 QR Scanned: $code");

                      context
                          .read<AttendanceBloc>()
                          .add(QRScanned(code));
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
