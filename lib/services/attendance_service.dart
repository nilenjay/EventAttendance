import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class AttendanceService {
  Future<void> markAttendance({
    required String studentNumber,
    required int day,
  }) async {
    final url =
        "https://api.programmingclub.live/api/attendance/day$day/";

    debugPrint("🌐 Sending to Day $day API");
    debugPrint("🌐 Student: $studentNumber");

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "studentNumber": studentNumber,
      }),
    );

    debugPrint("📡 Status Code: ${response.statusCode}");

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception("Backend returned ${response.statusCode}");
    }
  }
}
