import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ServiceSuspendedScreen extends StatelessWidget {
  final String reason;

  const ServiceSuspendedScreen({super.key, this.reason = ""});

  @override
  Widget build(BuildContext context) {
    // Prevent back button
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.red[50],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.block, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                const Text(
                  "Service Suspended",
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (reason.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      reason,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 40),
                const Text(
                  "Please contact support for assistance.",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    SystemNavigator.pop(); // Exit app
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Close App"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
