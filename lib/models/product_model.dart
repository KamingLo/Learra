class ProductModel {
  final String id;
  final String namaProduk;
  final String description;
  final int premiDasar;
  final String tipe;

  ProductModel({
    required this.id,
    required this.namaProduk,
    required this.description,
    required this.premiDasar,
    required this.tipe,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      // Sesuaikan 'id' atau '_id' tergantung response backend database kamu
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      namaProduk: json['namaProduk'] ?? '',
      description: json['description'] ?? '',
      premiDasar: int.tryParse(json['premiDasar'].toString()) ?? 0,
      tipe: json['tipe'] ?? 'kesehatan',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "namaProduk": namaProduk,
      "description": description,
      "premiDasar": premiDasar,
      "tipe": tipe,
    };
  }
}