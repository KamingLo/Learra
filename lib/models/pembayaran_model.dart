// lib/models/pembayaran_model.dart

class Pembayaran {
  final String id;
  final String policyId;
  final double amount;
  final String method;
  final String type; // "pembayaran_awal" atau "perpanjangan"
  final String status; // "menunggu_konfirmasi" | "berhasil" | "gagal"
  final DateTime createdAt;
  final DateTime updatedAt;

  // Data yang di-populate dari backend
  final PolisDetail? polis;

  Pembayaran({
    required this.id,
    required this.policyId,
    required this.amount,
    required this.method,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.polis,
  });

  factory Pembayaran.fromJson(Map<String, dynamic> json) {
    return Pembayaran(
      id: json['_id'] ?? json['id'],
      policyId: json['policyId'] is String
          ? json['policyId']
          : json['policyId']['_id'],
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : json['amount'],
      method: json['method'] ?? '',
      type: json['type'] ?? 'pembayaran_awal',
      status: json['status'] ?? 'menunggu_konfirmasi',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      polis: json['policyId'] is Map<String, dynamic>
          ? PolisDetail.fromJson(json['policyId'])
          : null,
    );
  }

  bool get isPending => status == 'menunggu_konfirmasi';
  bool get isSuccess => status == 'berhasil';
  bool get isFailed => status == 'gagal';

  String get statusDisplay {
    switch (status) {
      case 'menunggu_konfirmasi':
        return 'Menunggu Konfirmasi';
      case 'berhasil':
        return 'Berhasil';
      case 'gagal':
        return 'Gagal';
      default:
        return status;
    }
  }

  String get typeDisplay =>
      type == 'perpanjangan' ? 'Perpanjangan' : 'Pembayaran Awal';
}

class PolisDetail {
  final String id;
  final UserDetail? user;
  final ProductDetail? product;
  final String status;
  final DateTime startingDate;
  final DateTime endingDate;

  PolisDetail({
    required this.id,
    this.user,
    this.product,
    required this.status,
    required this.startingDate,
    required this.endingDate,
  });

  factory PolisDetail.fromJson(Map<String, dynamic> json) {
    return PolisDetail(
      id: json['_id'] ?? json['id'],
      user: json['userId'] is Map<String, dynamic>
          ? UserDetail.fromJson(json['userId'])
          : null,
      product: json['productId'] is Map<String, dynamic>
          ? ProductDetail.fromJson(json['productId'])
          : null,
      status: json['status'] ?? '-',
      startingDate: DateTime.parse(json['startingDate']),
      endingDate: DateTime.parse(json['endingDate']),
    );
  }
}

class UserDetail {
  final String id;
  final String name;
  final String email;

  UserDetail({required this.id, required this.name, required this.email});

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? 'Tidak ada nama',
      email: json['email'] ?? '-',
    );
  }
}

class ProductDetail {
  final String id;
  final String name;
  final double price;

  ProductDetail({required this.id, required this.name, required this.price});

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? 'Produk tidak diketahui',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] ?? 0.0),
    );
  }
}
