import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';

// ── Brand Palette ──────────────────────────────────────────────
const _red = Color(0xFFD32F2F);
const _redDark = Color(0xFF9A0007);
const _black = Color(0xFF0D0D0D);
const _cardBg = Color(0xFF1A1A1A);
const _surface = Color(0xFF242424);
const _white = Color(0xFFFFFFFF);
const _grey = Color(0xFF9E9E9E);
// ───────────────────────────────────────────────────────────────

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void showManualEntrySheet(BuildContext context) {
      final controller = TextEditingController();

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          return BlocBuilder<AttendanceBloc, AttendanceState>(
            bloc: context.read<AttendanceBloc>(),
            builder: (_, state) {
              return Container(
                decoration: const BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 28,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 28,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: _grey.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Text(
                      "Manual Entry",
                      style: TextStyle(
                        color: _white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Enter the student number below",
                      style: TextStyle(
                        color: _grey.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: _white, fontSize: 16),
                      cursorColor: _red,
                      decoration: InputDecoration(
                        hintText: "e.g. 2410010",
                        hintStyle: TextStyle(color: _grey.withOpacity(0.5)),
                        prefixIcon: const Icon(Icons.badge_outlined, color: _red),
                        filled: true,
                        fillColor: _surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: _red, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state.isScanningEnable ? _red : _surface,
                          foregroundColor: _white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: state.isScanningEnable ? 4 : 0,
                          shadowColor: _red.withOpacity(0.4),
                        ),
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
                        child: const Text(
                          "Submit",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
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
      backgroundColor: _black,
      appBar: AppBar(
        backgroundColor: _black,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              width: 8,
              height: 28,
              decoration: BoxDecoration(
                color: _red,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "QR Attendance",
              style: TextStyle(
                color: _white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: _surface,
          ),
        ),
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
              const SizedBox(height: 20),

              // ── Day Selector ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "SELECT DAY",
                      style: TextStyle(
                        color: _grey.withOpacity(0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: _cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _surface, width: 1),
                      ),
                      child: DropdownButtonFormField<int>(
                        value: state.selectedDay,
                        dropdownColor: _cardBg,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _red),
                        style: const TextStyle(color: _white, fontSize: 15),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.calendar_today_outlined, color: _red, size: 20),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
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
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Manual Entry Button ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _red,
                      side: const BorderSide(color: _red, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.keyboard_outlined, size: 20),
                    label: const Text(
                      "Enter Student Number Manually",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    onPressed: () => showManualEntrySheet(context),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Scanner Label ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      "SCAN QR CODE",
                      style: TextStyle(
                        color: _grey.withOpacity(0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: _surface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: state.isScanningEnable
                            ? _red.withOpacity(0.15)
                            : _surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: state.isScanningEnable ? _red : _grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: state.isScanningEnable ? _red : _grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            state.isScanningEnable ? "LIVE" : "BUSY",
                            style: TextStyle(
                              color: state.isScanningEnable ? _red : _grey,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── QR Scanner ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Scanner or loader
                        state.isLoading
                            ? Container(
                          color: _cardBg,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: _red,
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
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

                        // Corner brackets overlay
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _ScannerOverlayPainter(
                              active: state.isScanningEnable,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}

// ── Corner bracket overlay painter ────────────────────────────
class _ScannerOverlayPainter extends CustomPainter {
  final bool active;
  _ScannerOverlayPainter({required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final color = active ? _red : _grey;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 28.0;
    const r = 6.0;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(r, len)
        ..lineTo(r, r)
        ..arcToPoint(Offset(r + r, 0), radius: const Radius.circular(r))
        ..lineTo(len, 0),
      paint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, 0)
        ..lineTo(size.width - r * 2, 0)
        ..arcToPoint(Offset(size.width - r, r), radius: const Radius.circular(r))
        ..lineTo(size.width - r, len),
      paint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(r, size.height - len)
        ..lineTo(r, size.height - r)
        ..arcToPoint(Offset(r + r, size.height), radius: const Radius.circular(r))
        ..lineTo(len, size.height),
      paint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, size.height)
        ..lineTo(size.width - r * 2, size.height)
        ..arcToPoint(
            Offset(size.width - r, size.height - r),
            radius: const Radius.circular(r))
        ..lineTo(size.width - r, size.height - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ScannerOverlayPainter old) => old.active != active;
}