import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<Map<String, dynamic>> login(
    String id,
    String password,
    String? token,
  ) async {
    final url = Uri.parse("https://ibcabs.in/bills/api/driver.php");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "mode": 5,
          "username": id,
          "password": password,
          "tokenid": token ?? "",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          "success": data["status"] == "success",
          "data": data,
          "message": data["message"] ?? "Login successful",
        };
      } else {
        return {
          "success": false,
          "message": "Server error: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Network error. Please try again."};
    }
  }
}
