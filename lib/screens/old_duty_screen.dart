import 'package:flutter/material.dart';
import '../services/old_duty_service.dart';
import '../services/auth_service.dart';

class OldDutyScreen extends StatefulWidget {
  const OldDutyScreen({super.key});

  @override
  State<OldDutyScreen> createState() => _OldDutyScreenState();
}

class _OldDutyScreenState extends State<OldDutyScreen> {
  DateTime fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime toDate = DateTime.now();

  List duties = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOldDuties();
  }

  // 📅 Format date to YYYY-MM-DD
  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // 🔥 Fetch Old Duties
  Future<void> fetchOldDuties() async {
    setState(() => isLoading = true);

    try {
      final user = await AuthService.getUserDetails();

      String driverName = user['drivername'] ?? ""; // ✅ using drivername

      final data = await OldDutyService.fetchOldDuties(
        driverName: driverName,
        fromDate: formatDate(fromDate),
        toDate: formatDate(toDate),
      );

      setState(() {
        duties = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  // 📅 Date Picker
  Future<void> pickDate(bool isFrom) async {
    DateTime initialDate = isFrom ? fromDate : toDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });

      fetchOldDuties(); // 🔄 auto refresh
    }
  }

  // 🎨 Duty Card
  Widget dutyCard(dynamic duty) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${duty['date']} | ${duty['time']}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("👤 ${duty['party_name']} (${duty['party_number']})"),
            const SizedBox(height: 6),
            Text("📍 ${duty['start_point']} → ${duty['end_point']}"),
            const SizedBox(height: 6),
            Text("🚗 ${duty['car_number']}"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Old Duty")),

      body: Column(
        children: [
          // 🔹 DATE FILTERS
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => pickDate(true),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text("From: ${formatDate(fromDate)}"),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => pickDate(false),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text("To: ${formatDate(toDate)}"),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔹 DUTY LIST
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : duties.isEmpty
                ? const Center(child: Text("No Records Found"))
                : RefreshIndicator(
                    onRefresh: fetchOldDuties,
                    child: ListView.builder(
                      itemCount: duties.length,
                      itemBuilder: (context, index) {
                        return dutyCard(duties[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
