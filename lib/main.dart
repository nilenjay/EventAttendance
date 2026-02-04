import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/attendance_bloc.dart';
import 'screens/scanner_screen.dart';
import 'services/attendance_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AttendanceBloc(AttendanceService()),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ScannerScreen(),
      ),
    );
  }
}
