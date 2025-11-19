import 'dart:convert'; // Import ini untuk memformat JSON agar rapi
import 'package:flutter/material.dart';
import '../../services/api_service.dart'; // Pastikan path import sesuai struktur foldermu

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Panggil Service
    final apiService = ApiService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Users'),
        backgroundColor: Colors.blueAccent,
      ),
      // 2. Gunakan FutureBuilder untuk memanggil API saat halaman dibuka
      body: FutureBuilder(
        future: apiService.get('/users'), // Request ke BASE_URL + /users
        builder: (context, snapshot) {
          
          // KONDISI 1: Sedang Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // KONDISI 2: Terjadi Error (Misal token invalid atau server down)
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Terjadi Kesalahan:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          // KONDISI 3: Data Berhasil Didapat
          if (snapshot.hasData) {
            final data = snapshot.data;

            // Kita format JSON-nya biar enak dibaca (pretty print)
            // '  ' artinya indentasi 2 spasi
            final prettyJson = const JsonEncoder.withIndent('  ').convert(data);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Response JSON (Raw):",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    // Menampilkan Text JSON
                    child: Text(
                      prettyJson,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          // Default jika tidak ada data
          return const Center(child: Text("Tidak ada data ditemukan."));
        },
      ),
    );
  }
}