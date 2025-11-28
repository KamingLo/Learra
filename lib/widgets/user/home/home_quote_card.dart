import 'package:flutter/material.dart';

class HomeQuoteCard extends StatelessWidget {
  const HomeQuoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Divider(thickness: 0.8),
        SizedBox(height: 12),
        Text(
          "“Perlindungan hari ini adalah ketenangan untuk masa depan.”",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}