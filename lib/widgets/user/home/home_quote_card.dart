import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class HomeQuoteCard extends StatelessWidget {
  final VoidCallback? onBackToTop;

  const HomeQuoteCard({
    super.key,
    this.onBackToTop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(thickness: 0.8),
        const SizedBox(height: 12),
        const Text(
          "“Perlindungan hari ini adalah ketenangan untuk masa depan.”",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        InkWell(
          onTap: () {
            HapticFeedback.mediumImpact(); 
            onBackToTop?.call();
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.keyboard_arrow_up_rounded,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  "Kembali ke Atas",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}