import 'package:flutter/material.dart';
import '../../../models/polis_model.dart';
import 'user_polis_detail_screen.dart';

class UserPolisForm extends StatelessWidget {
  const UserPolisForm({super.key});

  @override
  Widget build(BuildContext context) {
    final examplePolicy = PolicyModel.dummyData[0];

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Test Navigasi ke Detail"),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PolicyDetailScreen(policy: examplePolicy),
                  ),
                );
              },
              child: const Text("Lihat Contoh Detail Polis"),
            ),

            const SizedBox(height: 20),

            Material(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PolicyDetailScreen(policy: examplePolicy),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  width: 220,
                  child: Row(
                    children: const [
                      Icon(Icons.visibility, color: Colors.green),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Cek Tampilan Detail",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
