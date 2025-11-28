class AdminUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String nomorIdentitas;
  final String address;
  final String pekerjaan;
  final String rentangGaji;
  final String birthDate;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.nomorIdentitas,
    required this.address,
    required this.pekerjaan,
    required this.rentangGaji,
    required this.birthDate,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    final birthRaw = json['birthDate']?.toString() ?? '';
    final trimmedBirth = birthRaw.length >= 10
        ? birthRaw.substring(0, 10)
        : birthRaw;

    return AdminUser(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '-',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      nomorIdentitas: json['nomorIdentitas']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      pekerjaan: json['pekerjaan']?.toString() ?? '',
      rentangGaji: json['rentangGaji']?.toString() ?? '',
      birthDate: trimmedBirth,
    );
  }
}
