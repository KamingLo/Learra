import 'package:flutter/material.dart';

class PolicyModel {
  final String id;
  final String policyNumber;
  final String productName;
  final String vehicleType;
  final String vehicleBrand;
  final String plateNumber;
  final String frameNumber;
  final String engineNumber;
  final String ownerName;
  final String yearBought;
  final double premiumAmount;
  final String status;
  final DateTime expiredDate;

  PolicyModel({
    required this.id,
    required this.policyNumber,
    required this.productName,
    required this.vehicleType,
    required this.vehicleBrand,
    required this.plateNumber,
    required this.frameNumber,
    required this.engineNumber,
    required this.ownerName,
    required this.yearBought,
    required this.premiumAmount,
    required this.status,
    required this.expiredDate,
  });

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

  IconData get vehicleIcon {
    return vehicleType.toLowerCase() == 'mobil'
        ? Icons.directions_car
        : Icons.motorcycle;
  }

  static List<PolicyModel> get dummyData => [
    PolicyModel(
      id: '1',
      policyNumber: '240512001',
      productName: 'Gold Ride',
      vehicleType: 'Mobil',
      vehicleBrand: 'Honda',
      plateNumber: 'B 2454 Ben',
      frameNumber: '2023JD2312HDS',
      engineNumber: '23012DSAD2312',
      ownerName: 'Kaming',
      yearBought: '2019',
      premiumAmount: 200000,
      status: 'Aktif',
      expiredDate: DateTime(2030, 12, 25),
    ),
    PolicyModel(
      id: '2',
      policyNumber: '240512002',
      productName: 'Gold Ride',
      vehicleType: 'Motor',
      vehicleBrand: 'Yamaha',
      plateNumber: 'B 1234 XYZ',
      frameNumber: '2023JD2312HDS',
      engineNumber: '23012DSAD2312',
      ownerName: 'Budi',
      yearBought: '2020',
      premiumAmount: 150000,
      status: 'Aktif',
      expiredDate: DateTime(2030, 12, 25),
    ),
  ];
}
