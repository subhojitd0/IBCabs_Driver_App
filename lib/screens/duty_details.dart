import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DutyDetailsScreen extends StatefulWidget {
  final String dutyId;

  const DutyDetailsScreen({super.key, required this.dutyId});

  @override
  State<DutyDetailsScreen> createState() => _DutyDetailsScreenState();
}

class _DutyDetailsScreenState extends State<DutyDetailsScreen> {
  dynamic dutyDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDutyDetails();
  }

  // 🔥 API CALL ON LOAD
  Future<void> fetchDutyDetails() async {
    try {
      final url = Uri.parse(
        "https://your-api-url.com/duty_details.php",
      ).replace(queryParameters: {'duty_id': widget.dutyId});

      final response = await http.get(url);
      final data = jsonDecode(response.body);

      setState(() {
        dutyDetails = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Duty Details")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : dutyDetails == null
          ? const Center(child: Text("No Data"))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Text(jsonEncode(dutyDetails)), // replace with UI later
            ),
    );
  }
}
