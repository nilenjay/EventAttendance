import 'dart:convert';
import 'package:http/http.dart' as http;

class AttendanceService {
  Future<void> markAttendance(String studentNumber) async {
    const url = "https://YOUR_BACKEND_ENDPOINT";

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "studentNumber": studentNumber,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to mark attendance");
    }
  }
}
