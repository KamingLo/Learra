import 'package:flutter/material.dart';
import '../services/session_service.dart';

class PolicyModel {
  final String id;
  final String policyNumber;
  final String productName;
  final String? productId;
  final String? productType;
  final double premiumAmount;
  final String status;
  final DateTime expiredDate;
  final DateTime? startDate;
  final DateTime? createdAt;
  final String ownerId;

  final String category;

  final String? vehicleBrand;
  final String? vehicleType;
  final String? plateNumber;
  final String? frameNumber;
  final String? engineNumber;
  final String? yearBought;
  final double? vehiclePrice;

  final String? vehicleOwnerName;
  final String? userName;
  final String? ownerName;
  final String? ownerEmail;

  final bool? hasDiabetes;
  final bool? isSmoker;
  final bool? hasHypertension;

  final int? dependentsCount;
  final String? maritalStatus;
  final String? statusReason;

  PolicyModel({
    required this.id,
    required this.policyNumber,
    required this.productName,
    this.productId,
    this.productType,
    required this.premiumAmount,
    required this.status,
    required this.expiredDate,
    this.startDate,
    this.createdAt,
    required this.ownerId,
    required this.category,
    this.vehicleBrand,
    this.vehicleType,
    this.plateNumber,
    this.frameNumber,
    this.engineNumber,
    this.yearBought,
    this.vehiclePrice,
    this.vehicleOwnerName,
    this.userName,
    this.ownerName,
    this.ownerEmail,
    this.hasDiabetes,
    this.isSmoker,
    this.hasHypertension,
    this.dependentsCount,
    this.maritalStatus,
    this.statusReason,
  });

  PolicyModel copyWith({
    String? productName,
    String? productType,
    String? userName,
    String? vehicleOwnerName,
  }) {
    return PolicyModel(
      id: id,
      policyNumber: policyNumber,
      productName: productName ?? this.productName,
      productId: productId,
      productType: productType ?? this.productType,
      premiumAmount: premiumAmount,
      status: status,
      expiredDate: expiredDate,
      startDate: startDate,
      createdAt: createdAt,
      ownerId: ownerId,
      category: category,
      vehicleBrand: vehicleBrand,
      vehicleType: vehicleType,
      plateNumber: plateNumber,
      frameNumber: frameNumber,
      engineNumber: engineNumber,
      yearBought: yearBought,
      vehiclePrice: vehiclePrice,

      userName: userName ?? this.userName,
      vehicleOwnerName: vehicleOwnerName ?? this.vehicleOwnerName,
      ownerName: userName ?? this.ownerName,

      ownerEmail: ownerEmail,
      hasDiabetes: hasDiabetes,
      isSmoker: isSmoker,
      hasHypertension: hasHypertension,
      dependentsCount: dependentsCount,
      maritalStatus: maritalStatus,
      statusReason: statusReason,
    );
  }

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDateOrNow(dynamic dateValue, {DateTime? fallback}) {
      final parsed = _parseDate(dateValue);
      if (parsed != null) return parsed;
      return fallback ?? DateTime.now().add(const Duration(days: 365));
    }

    DateTime? parseOptionalDate(dynamic dateValue) => _parseDate(dateValue);

    double parsePremium(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    dynamic rawProduct = json['productId'] ?? json['product'];
    String? parsedProductId;
    if (rawProduct is String) {
      parsedProductId = rawProduct;
    } else if (rawProduct is Map) {
      parsedProductId =
          rawProduct['_id']?.toString() ?? rawProduct['id']?.toString();
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

    dynamic userSource = json['userId'];

    String parsedOwnerId = '';
    if (userSource is String) {
      parsedOwnerId = userSource;
    } else if (userSource is Map) {
      parsedOwnerId =
          userSource['_id']?.toString() ?? userSource['id']?.toString() ?? '';
    }

    if (parsedOwnerId.isEmpty && json['user'] is Map) {
      parsedOwnerId =
          json['user']['id']?.toString() ??
          json['user']['_id']?.toString() ??
          '';
    }

    final Map<dynamic, dynamic>? userMap = (userSource is Map)
        ? userSource
        : (json['user'] is Map ? json['user'] : null);

    final rawDependents = jiwa?['jumlahTanggungan'];
    final int? parsedDependents = rawDependents is int
        ? rawDependents
        : int.tryParse(rawDependents?.toString() ?? '0');

    final String? parsedUserName =
        userMap?['name']?.toString() ?? json['userName']?.toString();

    final String? parsedVehicleOwner = kendaraan?['namaPemilik']?.toString();

    return PolicyModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      policyNumber: json['policyNumber'] ?? json['nomorPolis'] ?? '',
      productName:
          json['productName'] ??
          json['product']?['namaProduk'] ??
          'Produk Asuransi',
      productId: parsedProductId,
      productType:
          json['product']?['tipe']?.toString() ??
          json['productType']?.toString(),
      premiumAmount: parsePremium(
        json['premiumAmount'] ?? json['premi'] ?? json['premium'],
      ),
      status: json['status']?.toString() ?? 'Aktif',
      statusReason: json['statusReason']?.toString(),
      expiredDate: parseDateOrNow(
        json['expiredDate'] ?? json['endingDate'] ?? json['expireDate'],
      ),
      startDate: parseOptionalDate(
        json['startDate'] ?? json['startingDate'] ?? json['beginDate'],
      ),
      createdAt: parseOptionalDate(
        json['createdAt'] ??
            json['created_at'] ??
            json['createdAtUtc'] ??
            json['createdTime'],
      ),

      ownerId: parsedOwnerId,
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
      vehiclePrice: () {
        final rawPrice = kendaraan?['hargaKendaraan'];
        if (rawPrice == null) return null;
        if (rawPrice is num) return rawPrice.toDouble();
        return double.tryParse(rawPrice.toString());
      }(),

      userName: parsedUserName,
      vehicleOwnerName: parsedVehicleOwner,

      ownerName: parsedUserName,

      ownerEmail:
          userMap?['email']?.toString() ??
          json['userEmail']?.toString() ??
          json['email']?.toString(),

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
        return 'Kesehatan';
      case 'jiwa':
        return 'Jiwa';
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
          if (conditions.isEmpty) return 'Sehat';
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
        return 'No. Plat';
      case 'jiwa':
        return 'Status';
      case 'kesehatan':
        return 'Kondisi Kesehatan';
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

  String get formattedCreatedAt {
    if (createdAt == null) return '-';
    final date = createdAt!;
    return "${date.day}/${date.month}/${date.year}";
  }

  String get formattedStartDate {
    if (startDate == null) return '-';
    final date = startDate!;
    return "${date.day}/${date.month}/${date.year}";
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'aktif':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      try {
        return DateTime.parse(value);
      } catch (_) {}
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is Map && value.containsKey('\$date')) {
      return DateTime.fromMillisecondsSinceEpoch(value['\$date']);
    }
    return null;
  }
}
