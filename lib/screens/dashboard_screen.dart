import 'package:flutter/material.dart';
import '../screens/old_duty_screen.dart';
import '../services/auth_service.dart';
import '../services/duty_service.dart'; // ✅ IMPORTANT
import 'login_screen.dart'; // ✅ IMPORTANT
import 'package:url_launcher/url_launcher.dart';
import '../utils/snackbar_helper.dart';
import 'package:provider/provider.dart';
import '../utils/theme_helper.dart';

class DashboardScreen extends StatefulWidget {
  final String username;
  final String drivername;
  final bool triggerRefresh;

  const DashboardScreen({
    super.key,
    required this.username,
    required this.drivername,
    this.triggerRefresh = false,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  List duties = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchDuties(); // always load duties
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 👈 CLEANUP
    super.dispose();
  }

  DateTime? lastFetch;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      // 🔥 App came to foreground
      if (lastFetch == null ||
          DateTime.now().difference(lastFetch!) > const Duration(seconds: 5)) {
        fetchDuties();
        lastFetch = DateTime.now();
      }
    }
  }

  // 🔥 Fetch duties using DutyService
  Future<void> fetchDuties() async {
    try {
      final data = await DutyService.fetchDuties(widget.drivername);

      setState(() {
        duties = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching duties: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // ✅ Accept / Reject using DutyService
  Future<void> decideDuty(String dutyId, int decision) async {
    bool success = await DutyService.decideDuty(dutyId, decision);

    if (success) {
      SnackbarHelper.showSuccess(
        context,
        decision == 1 ? "Duty Accepted." : "Duty Rejected.",
      );

      fetchDuties(); // refresh list
    } else {
      SnackbarHelper.showError(context, "Failed to update duty. Try again.");
    }
  }

  Future<void> startDuty(String dutyId, int state) async {
    bool success = await DutyService.startDuty(dutyId, state);

    if (success) {
      SnackbarHelper.showSuccess(
        context,
        state == '1' ? "Duty Updated Successfully" : "Duty Closed Successfully",
      );
      fetchDuties(); // refresh dashboard
    } else {
      SnackbarHelper.showError(context, "Failed to start duty");
    }
  }

  // 4. Action Buttons
  Widget actionButtons(dynamic duty) {
    int status = int.tryParse(duty['status'].toString()) ?? 0;

    // ✅ CASE 1: Accept / Reject
    if (status == 1) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                bool? confirm = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Confirm Reject"),
                      content: const Text(
                        "Are you sure you want to reject this duty?",
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
                          child: const Text("Reject"),
                        ),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  decideDuty(duty['id'], 0);
                }
              },
              child: const Text(
                "Reject",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => decideDuty(duty['id'], 1),
              child: const Text("Accept"),
            ),
          ),
        ],
      );
    }
    // ✅ CASE 2: Start Duty
    else if (status == 99) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () async {
            bool? confirm = await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Confirm Duty Start"),
                  content: const Text(
                    "Are you sure you want to start this duty?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Start"),
                    ),
                  ],
                );
              },
            );

            if (confirm == true) {
              await startDuty(duty['id'], 1);
            }
          },

          child: const Text(
            "Start Duty",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    // ✅ CASE 2: In Progress
    else if (status == 101) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () async {
            bool? confirm = await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Confirm Duty End"),
                  content: const Text(
                    "Are you sure you want to End this duty?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("End"),
                    ),
                  ],
                );
              },
            );

            if (confirm == true) {
              await startDuty(duty['id'], 2);
            }
          },

          child: const Text(
            "Close Duty",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // ❌ Default (no buttons)
    return const SizedBox();
  }

  // 🎨 Duty Card UI
  Widget dutyCard(dynamic duty) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor, // ✅ dynamic
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : Colors.blueGrey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1), // ✅ dynamic
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ), // ✅ dynamic
                    const SizedBox(width: 8),
                    Text(
                      "${duty['date']}",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.bodyLarge?.color, // ✅ dynamic
                      ),
                    ),
                  ],
                ),
                Text(
                  "${duty['time']}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PARTY INFO
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withOpacity(
                        0.2,
                      ),
                      child: Icon(
                        Icons.person,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            duty['party_name'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              final Uri url = Uri(
                                scheme: 'tel',
                                path: duty['party_number'].toString(),
                              );
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              }
                            },
                            child: Text(
                              duty['party_number'],
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // CAR TAG
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        duty['car_number'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Divider(height: 1),
                ),

                // LOCATION
                Row(
                  children: [
                    Column(
                      children: [
                        const Icon(
                          Icons.radio_button_checked,
                          size: 18,
                          color: Colors.green,
                        ),
                        Container(width: 2, height: 20, color: Colors.grey),
                        const Icon(
                          Icons.location_on,
                          size: 18,
                          color: Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            duty['start_point'],
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            duty['end_point'],
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // BUTTONS
                actionButtons(duty),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),

      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Text(
                "Welcome ${widget.drivername}",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),

            // 🔹 Old Duty
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Old Duty"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OldDutyScreen()),
                );
              },
            ),

            const Divider(),

            // 🔴 Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await AuthService.logout();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),

            const Divider(),

            // 🌙 DARK MODE TOGGLE (ADD HERE)
            SwitchListTile(
              title: const Text("Dark Mode"),
              secondary: const Icon(Icons.dark_mode),
              value: context.watch<ThemeService>().isDark,
              onChanged: (value) {
                context.read<ThemeService>().toggleTheme(value);
              },
            ),
          ],
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : duties.isEmpty
          ? const Center(child: Text("No Duties Available"))
          : RefreshIndicator(
              onRefresh: fetchDuties,
              child: ListView.builder(
                itemCount: duties.length,
                itemBuilder: (context, index) {
                  return dutyCard(duties[index]);
                },
              ),
            ),
    );
  }
}
