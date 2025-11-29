# Learra - Aplikasi Asuransi Flutter

**Learra** adalah aplikasi mobile berbasis Flutter yang memudahkan pengguna untuk membeli asuransi, mengecek polis, melakukan pembayaran, dan mengajukan klaim secara mudah dan cepat.

Aplikasi ini dirancang untuk memberikan pengalaman yang sederhana namun lengkap bagi pengguna dalam mengelola produk asuransi mereka.

## Fitur Utama

* **Beli Asuransi:** Pengguna dapat memilih produk asuransi yang tersedia dan membeli polis langsung dari aplikasi.
* **Cek Polis:** Memeriksa detail polis yang sudah dimiliki, termasuk status dan informasi lengkap.
* **Pembayaran:** Melakukan pembayaran premi atau polis secara aman melalui integrasi metode pembayaran.
* **Klaim:** Mengajukan klaim asuransi dengan mengunggah dokumen yang diperlukan dan memonitor status klaim.

## Teknologi

* **Frontend:** Flutter
* **Backend:** [Learra Backend](https://github.com/kaminglo/learra-backend) (Express.js + MongoDB)
* **Database:** MongoDB
* **State Management:** Provider / Riverpod (sesuaikan jika menggunakan)

## Instalasi & Jalankan

1. Clone repository ini:

```bash
git clone https://github.com/kaminglo/learra.git
```

2. Masuk ke direktori proyek:

```bash
cd learra
```

3. Install dependencies:

```bash
flutter pub get
```

4. Jalankan aplikasi di emulator atau perangkat nyata:

```bash
flutter run
```

> Pastikan backend sudah berjalan agar aplikasi dapat mengambil data polis, pembayaran, dan klaim.


## Kontribusi

Kontribusi sangat disambut! Silakan buat **pull request** atau **issue** jika menemukan bug atau ingin menambahkan fitur baru.