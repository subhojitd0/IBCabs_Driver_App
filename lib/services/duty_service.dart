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
}
