import 'dart:convert';
import 'package:http/http.dart' as http;

class InvoiceService {
  static Future<dynamic> fetchInvoice(String dutyId) async {
    final url = Uri.parse(
      "https://bookings.ibcabs.in/checkbooking/api/appdutyinvoice.php",
    ).replace(queryParameters: {"duty_id": dutyId});

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load invoice");
    }
  }

  static Future<bool> closeDuty(String dutyId) async {
    try {
      final url = Uri.parse(
        "https://bookings.ibcabs.in/checkbooking/api/appdutyclose.php",
      ).replace(queryParameters: {"duty_id": dutyId});

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        return false;
      }
    } catch (e) {
      print("Close Duty Error: $e");
      return false;
    }
  }
}
