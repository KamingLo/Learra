import 'package:flutter/material.dart';

class FormSectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const FormSectionCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final MaterialColor color;

  const InfoCard({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.color = Colors.blue,
  });

  const InfoCard.info({
    super.key,
    required this.message,
    this.title = "Informasi",
  }) : icon = Icons.info_outline,
       color = Colors.blue;

  const InfoCard.warning({
    super.key,
    required this.message,
    this.title = "Perhatian",
  }) : icon = Icons.warning_amber_outlined,
       color = Colors.orange;

  const InfoCard.tip({super.key, required this.message, this.title = "Tips"})
    : icon = Icons.lightbulb_outline,
      color = Colors.purple;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.shade900,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorMessageCard extends StatelessWidget {
  final String message;

  const ErrorMessageCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );
  }
}

class ProductInfoCard extends StatelessWidget {
  final String productName;
  final String productType;
  final IconData? icon;

  const ProductInfoCard({
    super.key,
    required this.productName,
    required this.productType,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon ?? _getDefaultIcon(productType),
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Asuransi $productType",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDefaultIcon(String type) {
    switch (type.toLowerCase()) {
      case 'kendaraan':
        return Icons.directions_car;
      case 'kesehatan':
        return Icons.local_hospital;
      case 'jiwa':
        return Icons.favorite;
      default:
        return Icons.shield;
    }
  }
}

class MaritalStatusInfoCard extends StatelessWidget {
  final String status;

  const MaritalStatusInfoCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final info = _getStatusInfo(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [info.color.shade50, info.color.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: info.color.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: info.color.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(info.icon, color: info.color.shade700, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Status: ${_capitalizeFirst(status)}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: info.color.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: info.color.shade700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _StatusInfo _getStatusInfo(String status) {
    switch (status) {
      case 'menikah':
        return _StatusInfo(
          color: Colors.blue,
          icon: Icons.favorite,
          description:
              'Status menikah biasanya memiliki premi lebih rendah karena dianggap memiliki gaya hidup lebih stabil.',
        );
      case 'cerai':
        return _StatusInfo(
          color: Colors.orange,
          icon: Icons.people_outline,
          description:
              'Status cerai akan diperhitungkan dalam kalkulasi premi berdasarkan jumlah tanggungan.',
        );
      default:
        return _StatusInfo(
          color: Colors.green,
          icon: Icons.person,
          description:
              'Status belum menikah dengan tanggungan minimal akan mendapat premi dasar.',
        );
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

class _StatusInfo {
  final MaterialColor color;
  final IconData icon;
  final String description;

  const _StatusInfo({
    required this.color,
    required this.icon,
    required this.description,
  });
}
