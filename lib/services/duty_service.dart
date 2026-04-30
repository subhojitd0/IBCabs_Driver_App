import 'dart:convert';
import 'package:http/http.dart' as http;

class DutyService {
  static Future<List> fetchDuties(String driverName) async {
    final url = Uri.parse(
      "https://bookings.ibcabs.in/checkbooking/api/appdutycheck.php",
    ).replace(queryParameters: {'driver': driverName});

    final response = await http.get(url);

    final data = jsonDecode(response.body);
    return data['data'] ?? [];
  }

  static Future<bool> decideDuty(String dutyId, int decision) async {
    final response = await http.post(
      Uri.parse(
        "https://bookings.ibcabs.in/checkbooking/api/appdutydecide.php",
      ),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"duty_id": dutyId, "dutydecide": decision}),
    );

    final data = jsonDecode(response.body);
    return data['success'] == true;
  }

  static Future<bool> submitDutyData({
    required String dutyId,
    required int state,
    required String km,
    required double latitude,
    required double longitude,
    String? parking,
    String? toll,
  }) async {
    try {
      final now = DateTime.now();

      final date =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final time =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      final response = await http.post(
        Uri.parse(
          "https://bookings.ibcabs.in/checkbooking/api/appdutyupdate.php",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "duty_id": dutyId,
          "dutystate": state,
          "dutydate": date,
          "dutytime": time,
          "dutykm": km,
          "parking": parking,
          "toll": toll,
          "latitude": latitude,
          "longitude": longitude,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }

      return false;
    } catch (e) {
      print("Submit Duty Error: $e");
      return false;
    }
  }
}
