import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class AttendanceService {
  Future<void> markAttendance(String studentNumber) async {
    debugPrint("🌐 Sending student number: $studentNumber");

    const url = "https://api.programmingclub.live/api/attendance/day1/";

    try {
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
      debugPrint("📦 Response Body: ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Backend returned ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("🔥 Network error: $e");
      rethrow;
    }
  }
}
