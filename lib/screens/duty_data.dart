import 'package:flutter/material.dart';
import '../services/duty_service.dart';
import '../utils/snackbar_helper.dart';

class DutyDataScreen extends StatefulWidget {
  final String dutyId;
  final int state;

  const DutyDataScreen({super.key, required this.dutyId, required this.state});

  @override
  State<DutyDataScreen> createState() => _DutyDataScreenState();
}

class _DutyDataScreenState extends State<DutyDataScreen> {
  final kmController = TextEditingController();
  final parkingController = TextEditingController();
  final tollController = TextEditingController();

  bool isLoading = false;

  String get title => widget.state == 1 ? "Start Duty KM" : "Stop Duty KM";

  String get successMessage => widget.state == 1
      ? "Duty started successfully"
      : "Duty closed successfully";

  Future<void> submit() async {
    String km = kmController.text.trim();
    String parking = parkingController.text.trim(); // ✅ NEW
    String toll = tollController.text.trim(); // ✅ NEW

    // ✅ Validation
    if (km.isEmpty) {
      SnackbarHelper.showError(context, "Please enter KM value");
      return;
    }

    if (widget.state == 2) {
      if (parking.isEmpty || toll.isEmpty) {
        SnackbarHelper.showError(
          context,
          "Please enter parking and toll charges",
        );
        return;
      }
    }

    // ✅ Confirmation popup
    bool? confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm"),
        content: Text("Are you sure you want to proceed?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isLoading = true);

    bool success = await DutyService.submitDutyData(
      dutyId: widget.dutyId,
      state: widget.state,
      km: km,
      parking: parking, // ✅ NEW
      toll: toll, // ✅ NEW
    );

    setState(() => isLoading = false);

    if (success) {
      SnackbarHelper.showSuccess(context, successMessage);

      // 🔥 Go back and trigger refresh
      Navigator.pop(context, true);
    } else {
      SnackbarHelper.showError(context, "Something went wrong");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: kmController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: title,
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Show only when state == 2
            if (widget.state == 2) ...[
              TextField(
                controller: parkingController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Parking Charges",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: tollController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Toll Charges",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
            ],

            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submit,
                      child: const Text("Submit"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
