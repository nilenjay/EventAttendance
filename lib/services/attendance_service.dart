import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AttendanceService {
  Future<void> markAttendance({
    required String studentNumber,
    required int day,
  }) async {
    final url = "https://api.programmingclub.live/api/attendance/day$day";

    debugPrint("🌐 Sending to Day $day API");
    debugPrint("🌐 Student: $studentNumber");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "studentNumber": studentNumber,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception("Request timed out. Please try again."),
      );

      debugPrint("📡 Status Code: ${response.statusCode}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        String errorMessage = "Something went wrong. Please try again.";
        try {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          if (body['message'] != null) {
            errorMessage = body['message'].toString();
          } else if (body['detail'] != null) {
            errorMessage = body['detail'].toString();
          }
        } catch (_) {
          // body wasn't JSON — keep default message
        }
        throw Exception(errorMessage);
      }

    } on SocketException {
      throw Exception("No internet connection. Please check your network.");
    } on Exception {
      rethrow;
    }
  }
}