import 'package:flutter/material.dart';

class OldDutyScreen extends StatelessWidget {
  const OldDutyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Old Duty")),
      body: const Center(child: Text("Old Duty Records will appear here")),
    );
  }
}
