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

  String formatTime(String? time) {
    if (time == null || time.isEmpty) return "-";

    try {
      final parts = time.split('.');
      final cleanTime = parts[0];

      final timeParts = cleanTime.split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      final period = hour >= 12 ? "PM" : "AM";
      hour = hour % 12;
      hour = hour == 0 ? 12 : hour;

      return "$hour:${minute.toString().padLeft(2, '0')} $period";
    } catch (e) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Invoice"),
        automaticallyImplyLeading: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : data == null
          ? const Center(child: Text("No Data"))
          : Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
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
                            if (data['duty_type'].toString() ==
                                'Local Rental') ...[
                              buildRow(
                                "Package",
                                "${data['hr']} hr / ${data['km']} km @ Rs. ${data['baserate']}",
                              ),
                              buildRow(
                                "Additional",
                                "Extra Km/Hr Rate : ${data['extrakmrate']}/${data['extrahrrate']}",
                              ),
                            ] else ...[
                              buildRow("Package", data['baserate']),
                            ],
                            const Divider(height: 15),
                            buildRow("Duty Type", data['duty_type']),
                            buildRow(
                              "Time",
                              "${formatTime(data['start_time'])} to ${formatTime(data['stop_time'])}",
                            ),

                            buildRow(
                              "KM",
                              "${data['start_km']} to ${data['stop_km']} (${int.parse(data['stop_km']) - int.parse(data['start_km'])} km)",
                            ),
                            const Divider(height: 15),
                            buildRow("Parking", "(+) ${data['parking']}"),
                            buildRow("Toll", "(+) ${data['toll']}"),
                            buildRow("Discount", "(-) ${data['discount']}"),
                            const Divider(height: 40),
                            buildRow(
                              "Amount",
                              "₹ ${data['amount']}",
                              isBold: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // 💰 Buttons
                      Row(
                        children: [
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
                                      "Collect Rs.${data['amount']} from ${data['party_name']}",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
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

                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.all(14),
                              ),
                              onPressed: () async {
                                final upiId = "subhojitd0@okhdfcbank";
                                final name = data['party_name'] ?? "Customer";
                                final amount = int.parse(data['amount']);
                                final note =
                                    "Payment for Duty ID ${data['id']}";

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
                                          QrImageView(
                                            data: upiUrl,
                                            version: QrVersions.auto,
                                            size: 220,
                                            backgroundColor: Colors.white,
                                            errorCorrectionLevel:
                                                QrErrorCorrectLevel.H,
                                            embeddedImage: const AssetImage(
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
                                            onPressed: () =>
                                                Navigator.pop(context),
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

                      // 🔴 END DUTY
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
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
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
              ),
            ),
    );
  }

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
