import 'dart:convert';
import 'package:http/http.dart' as http;

class OldDutyService {
  static Future<List> fetchOldDuties({
    required String driverName,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("https://bookings.ibcabs.in/checkbooking/api/appoldduty.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "drivername": driverName,
          "from_date": fromDate,
          "to_date": toDate,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        print("HTTP Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Old Duty Error: $e");
      return [];
    }
  }
}
