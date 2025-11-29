import 'package:flutter/material.dart';
import '../../../models/polis_model.dart';
import 'user_policy_card.dart';

class HomePolicyCard extends StatelessWidget {
  final bool isLoggedIn;
  final bool isLoading;
  final VoidCallback onLoginTap;
  final List<PolicyModel> policies;
  final Function(PolicyModel)? onPolicyTap;
  final Color primaryColor;

  const HomePolicyCard({
    super.key,
    required this.isLoggedIn,
    required this.onLoginTap,
    this.isLoading = false,
    this.policies = const [],
    this.onPolicyTap,
    this.primaryColor = const Color(0xFF0FA958),
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha:0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Akses Penuh",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Masuk untuk melihat polis Anda.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onLoginTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Masuk", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    if (isLoading) {
      return SizedBox(
        height: 240,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 2,
          padding: const EdgeInsets.only(bottom: 10),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Container(
              width: 300,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
            );
          },
        ),
      );
    }

    if (policies.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.shield_outlined, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text(
              "Belum ada polis aktif",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: policies.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 320,
            child: PolicyCard(
              policy: policies[index],
              onTap: () => onPolicyTap?.call(policies[index]),
            ),
          );
        },
      ),
    );
  }
}