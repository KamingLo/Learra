import 'package:flutter/material.dart';
import '../services/session_service.dart';

class PolicyModel {
  final String id;
  final String policyNumber;
  final String productName;
  final double premiumAmount;
  final String status;
  final DateTime expiredDate;
  final String ownerId;

  final String category;

  final String? vehicleBrand;
  final String? vehicleType;
  final String? plateNumber;
  final String? frameNumber;
  final String? engineNumber;
  final String? yearBought;
  final String? ownerName;

  final bool? hasDiabetes;
  final bool? isSmoker;
  final bool? hasHypertension;

  final int? dependentsCount;
  final String? maritalStatus;

  PolicyModel({
    required this.id,
    required this.policyNumber,
    required this.productName,
    required this.premiumAmount,
    required this.status,
    required this.expiredDate,
    required this.ownerId,
    required this.category,
    this.vehicleBrand,
    this.vehicleType,
    this.plateNumber,
    this.frameNumber,
    this.engineNumber,
    this.yearBought,
    this.ownerName,
    this.hasDiabetes,
    this.isSmoker,
    this.hasHypertension,
    this.dependentsCount,
    this.maritalStatus,
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    DateTime parseExpiredDate(dynamic dateValue) {
      if (dateValue is String) return DateTime.parse(dateValue);
      if (dateValue is Map && dateValue.containsKey('\$date')) {
        return DateTime.fromMillisecondsSinceEpoch(dateValue['\$date']);
      }
      return DateTime.now().add(const Duration(days: 365));
    }

    double parsePremium(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    final detail = json['detail'] as Map<String, dynamic>?;
    final kendaraan = detail?['kendaraan'] as Map<String, dynamic>?;
    final kesehatan = detail?['kesehatan'] as Map<String, dynamic>?;
    final jiwa = detail?['jiwa'] as Map<String, dynamic>?;

    String determinedCategory = 'umum';
    if (kendaraan != null) {
      determinedCategory = 'kendaraan';
    } else if (kesehatan != null) {
      determinedCategory = 'kesehatan';
    } else if (jiwa != null) {
      determinedCategory = 'jiwa';
    }

    if (determinedCategory == 'umum') {
      final pType = (json['product']?['tipe'] ?? json['productType'])
          ?.toString()
          .toLowerCase();
      if (pType != null) {
        determinedCategory = pType;
      }
    }

    final ownerId =
        json['userId']?.toString() ??
        json['user']?['id']?.toString() ??
        json['user']?['_id']?.toString() ??
        '';

    final rawDependents = jiwa?['jumlahTanggungan'];
    final int? parsedDependents = rawDependents is int
        ? rawDependents
        : int.tryParse(rawDependents?.toString() ?? '0');

    return PolicyModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      policyNumber: json['policyNumber'] ?? json['nomorPolis'] ?? '',
      productName:
          json['productName'] ??
          json['product']?['namaProduk'] ??
          'Produk Asuransi',
      premiumAmount: parsePremium(
        json['premiumAmount'] ?? json['premi'] ?? json['premium'],
      ),
      status: json['status']?.toString() ?? 'Aktif',
      expiredDate: parseExpiredDate(
        json['expiredDate'] ?? json['endingDate'] ?? json['expireDate'],
      ),
      ownerId: ownerId,
      category: determinedCategory,

      vehicleBrand: kendaraan?['merek']?.toString(),
      vehicleType: kendaraan?['jenisKendaraan']?.toString() ?? 'Kendaraan',
      plateNumber:
          kendaraan?['nomorKendaraan']?.toString() ??
          kendaraan?['nomorPolisi']?.toString(),
      frameNumber: kendaraan?['nomorRangka']?.toString(),
      engineNumber: kendaraan?['nomorMesin']?.toString(),
      yearBought:
          kendaraan?['tahunPembelian']?.toString() ??
          kendaraan?['umurKendaraan']?.toString(),
      ownerName: kendaraan?['namaPemilik']?.toString() ?? json['user']?['name'],

      hasDiabetes: kesehatan?['diabetes'],
      isSmoker: kesehatan?['merokok'],
      hasHypertension: kesehatan?['hipertensi'],

      dependentsCount: parsedDependents,
      maritalStatus: jiwa?['statusPernikahan']?.toString(),
    );
  }

  IconData get icon {
    switch (category.toLowerCase()) {
      case 'kesehatan':
        return Icons.medical_services_outlined;
      case 'jiwa':
        return Icons.family_restroom;
      case 'kendaraan':
        return Icons.directions_car_outlined;
      default:
        return Icons.shield_outlined;
    }
  }

  String get summaryTitle {
    switch (category.toLowerCase()) {
      case 'kendaraan':
        return vehicleBrand ?? 'Kendaraan';
      case 'kesehatan':
        return 'Proteksi Kesehatan';
      case 'jiwa':
        return 'Proteksi Jiwa';
      default:
        return 'Asuransi Umum';
    }
  }

  String get summarySubtitle {
    switch (category.toLowerCase()) {
      case 'kendaraan':
        return vehicleType ?? '-';
      case 'kesehatan':
        {
          List<String> conditions = [];
          if (hasDiabetes == true) {
            conditions.add('Diabetes');
          }
          if (hasHypertension == true) {
            conditions.add('Hipertensi');
          }
          if (isSmoker == true) {
            conditions.add('Perokok');
          }
          if (conditions.isEmpty) return 'Sehat / Tidak ada riwayat';
          return conditions.join(', ');
        }
      case 'jiwa':
        return '${dependentsCount ?? 0} Tanggungan';
      default:
        return '-';
    }
  }

  String get primaryDetailLabel {
    switch (category.toLowerCase()) {
      case 'kendaraan':
        return 'No. Polisi';
      case 'jiwa':
        return 'Status';
      case 'kesehatan':
        return 'Kondisi';
      default:
        return 'Info';
    }
  }

  String get primaryDetailValue {
    switch (category.toLowerCase()) {
      case 'kendaraan':
        return plateNumber ?? '-';
      case 'jiwa':
        return maritalStatus ?? '-';
      case 'kesehatan':
        {
          final bool isHighRisk =
              (hasDiabetes == true) || (hasHypertension == true);
          return isHighRisk ? 'Berisiko' : 'Standard';
        }
      default:
        return '-';
    }
  }

  Future<bool> belongsToCurrentUser() async {
    final sessionId = await SessionService.getCurrentId();
    if (sessionId == null || sessionId.isEmpty) return false;
    return sessionId == ownerId;
  }

  String get formattedDate {
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return "${expiredDate.day} ${months[expiredDate.month]} ${expiredDate.year}";
  }

  String get formattedPrice {
    return "Rp${premiumAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  Color get statusColor {
    return status.toLowerCase() == 'aktif' ? Colors.green : Colors.orange;
  }
}
