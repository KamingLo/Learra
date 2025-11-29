import 'package:flutter/material.dart';
import '../../../models/polis_model.dart';

class PolicyCard extends StatelessWidget {
  final PolicyModel policy;
  final VoidCallback? onTap;

  const PolicyCard({super.key, required this.policy, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.green.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        policy.icon,
                        color: Colors.green.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  policy.productName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildStatusBadge(),
                            ],
                          ),

                          const SizedBox(height: 6),

                          Text(
                            policy.category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade400,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: 6),

                          _buildDynamicSubtitle(policy),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.shade200,
                        Colors.grey.shade100,
                        Colors.grey.shade200,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.badge_outlined,
                        "No. Polis",
                        policy.policyNumber,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.shade200,
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        policy.category == 'kendaraan'
                            ? Icons.directions_car_outlined
                            : (policy.category == 'jiwa'
                                  ? Icons.favorite_border
                                  : Icons.medical_information_outlined),
                        policy.primaryDetailLabel,
                        policy.primaryDetailValue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Berakhir pada",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            policy.formattedDate,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Premi/Bulan",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            policy.formattedPrice,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicSubtitle(PolicyModel p) {
    String textToDisplay = "";

    if (p.category.toLowerCase() == 'kesehatan') {
      List<String> conditions = [];
      if (p.hasDiabetes == true) conditions.add('Diabetes');
      if (p.isSmoker == true) conditions.add('Perokok');
      if (p.hasHypertension == true) conditions.add('Hipertensi');

      if (conditions.isNotEmpty) {
        textToDisplay = conditions.join(' | ');
      } else {
        textToDisplay = "Sehat";
      }
    } else if (p.category.toLowerCase() == 'jiwa') {
      textToDisplay = p.summarySubtitle;
    } else {
      textToDisplay = "${p.summaryTitle} • ${p.summarySubtitle}";
    }

    return Text(
      textToDisplay,
      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: policy.statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: policy.statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: policy.statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            policy.status,
            style: TextStyle(
              color: policy.statusColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
