import 'package:flutter/material.dart';
import '../services/invoice_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DutyInvoiceScreen extends StatefulWidget {
  final String dutyId;

  const DutyInvoiceScreen({super.key, required this.dutyId});

  @override
  State<DutyInvoiceScreen> createState() => _DutyInvoiceScreenState();
}

class _DutyInvoiceScreenState extends State<DutyInvoiceScreen> {
  dynamic data;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInvoice();
  }

  Future<void> fetchInvoice() async {
    try {
      final res = await InvoiceService.fetchInvoice(widget.dutyId);

      setState(() {
        data = res['data'];
        isLoading = false;
      });
    } catch (e) {
      print("Invoice Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Invoice"),
        automaticallyImplyLeading: true, // ✅ BACK BUTTON ENABLED
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : data == null
          ? const Center(child: Text("No Data"))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 💎 Premium Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).cardColor,
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 12,
                          color: Colors.black12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildRow("Party Name", data['party_name']),
                        buildRow("Contact", data['party_number']),
                        buildRow("Duty Type", data['duty_type']),
                        buildRow("Start Time", data['start_time']),
                        buildRow("Start KM", data['start_km']),
                        buildRow("Stop Time", data['stop_time']),
                        buildRow("Stop KM", data['stop_km']),
                        buildRow("Comment", data['comment']),

                        const Divider(height: 25),

                        buildRow("Amount", "₹ ${data['amount']}", isBold: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  // 💰 Buttons
                  Row(
                    children: [
                      // 💵 CASH
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.all(14),
                          ),
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Payment"),
                                content: Text(
                                  "Collect Rs.${data['amount']} from ${data['party_name']} ",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // close dialog
                                    },
                                    child: const Text("OK"),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text("Pay by Cash"),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // 📱 UPI
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.all(14),
                          ),
                          onPressed: () async {
                            final upiId =
                                "subhojitd0@okhdfcbank"; // 🔴 CHANGE THIS
                            final name = data['party_name'] ?? "Customer";
                            final amount = int.parse(data['amount']);
                            final note = "Payment for Duty ID $data['id']";
                            final upiUrl =
                                "upi://pay?pa=$upiId&pn=$name&am=$amount&cu=INR&tn=$note";

                            await showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "Scan to Pay",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      // ✅ QR GENERATED HERE
                                      QrImageView(
                                        data: upiUrl,
                                        version: QrVersions.auto,
                                        size: 220.0,
                                        backgroundColor: Colors.white,
                                        errorCorrectionLevel:
                                            QrErrorCorrectLevel.H,
                                        embeddedImage: AssetImage(
                                          "assets/images/app_logo.png",
                                        ),
                                        embeddedImageStyle:
                                            const QrEmbeddedImageStyle(
                                              size: Size(40, 40),
                                            ),
                                      ),

                                      const SizedBox(height: 12),

                                      Text(
                                        "₹ $amount",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      Text(
                                        name,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Close"),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          child: const Text("Pay by UPI"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 🔴 END DUTY BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        bool? confirm = await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("End Duty"),
                            content: const Text(
                              "Are you sure you want to end this duty?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("End"),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          bool success = await InvoiceService.closeDuty(
                            widget.dutyId,
                          );

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Duty closed successfully"),
                              ),
                            );

                            // 🔥 GO BACK TO DASHBOARD
                            Navigator.pop(context, true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Failed to close duty"),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        "End Duty",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // 🔹 Helper UI
  Widget buildRow(String label, dynamic value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value?.toString() ?? "-",
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
