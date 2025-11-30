import 'package:flutter/material.dart';

class FAQItem {
  final String category;
  final String question;
  final String answer;

  FAQItem({
    required this.category,
    required this.question,
    required this.answer,
  });
}

class DeveloperItem {
  final String name;
  final String role;
  final String github;
  final String assetPath;

  DeveloperItem({
    required this.name,
    required this.role,
    required this.github,
    required this.assetPath,
  });
}

class DeveloperCard extends StatelessWidget {
  final DeveloperItem developer;

  const DeveloperCard({super.key, required this.developer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                developer.assetPath,
                fit: BoxFit.cover,
                errorBuilder:
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      return Center(
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.grey[600],
                        ),
                      );
                    },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  developer.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  developer.role,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'GitHub: ${developer.github}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blue[600],
                    fontStyle: FontStyle.italic,
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

class ContactBox extends StatelessWidget {
  const ContactBox({super.key});

  @override
  Widget build(BuildContext context) {
    const String phoneNumber = '+6283835360789';

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 184, 185, 185),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Butuh Bantuan Lebih Lanjut?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Jika butuh bantuan lebih lanjut, Silahkan hubungi nomor telepon ini. Kami siap membantu 24/7',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.phone_in_talk,
                    color: Color.fromARGB(255, 255, 255, 255),
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    phoneNumber,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FAQCard extends StatelessWidget {
  final FAQItem item;
  final bool isExpanded;
  final VoidCallback onTap;

  const FAQCard({
    super.key,
    required this.item,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isExpanded
                ? const Color(0xFFD1D5DB)
                : const Color(0xFFE5E7EB),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.question,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.expand_more,
                      color: Color(0xFF9CA3AF),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            if (isExpanded)
              Container(height: 1, color: const Color(0xFFF3F4F6)),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  item.answer,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6B7280),
                    height: 1.6,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  String? expandedQuestionIndex;
  Set<String> expandedCategories = {};

  final List<DeveloperItem> developers = [
    DeveloperItem(
      name: 'Charless',
      role: '535240068',
      github: 'LessThanNone',
      assetPath: 'assets/Author/charless.png',
    ),
    DeveloperItem(
      name: 'Fabio Fransisco',
      role: '535240077',
      github: 'FabioCoco',
      assetPath: 'assets/Author/fabio.png',
    ),
    DeveloperItem(
      name: 'Joe Nickson Lie',
      role: '535240079',
      github: 'Tuknwm',
      assetPath: 'assets/Author/joe.png',
    ),
    DeveloperItem(
      name: 'Kaming Lo',
      role: '535240175',
      github: 'KamingLo',
      assetPath: 'assets/Author/kaming.png',
    ),
    DeveloperItem(
      name: 'Michael Andre',
      role: '535240080',
      github: 'Mikeee636',
      assetPath: 'assets/Author/michael.png',
    ),
  ];

  final List<FAQItem> faqItems = [
    FAQItem(
      category: 'Polis',
      question: 'Bagaimana cara membeli polis asuransi di Learra?',
      answer:
          'Anda dapat membeli polis melalui aplikasi Learra dengan mudah. Pilih jenis asuransi yang Anda inginkan (Jiwa, Kesehatan, atau Mobil), isi data diri, pilih paket premium, dan lakukan pembayaran. Polis akan aktif setelah verifikasi.',
    ),
    FAQItem(
      category: 'Polis',
      question: 'Berapa lama proses persetujuan polis asuransi?',
      answer:
          'Proses persetujuan polis biasanya memakan waktu 1-2 hari kerja setelah semua dokumen lengkap. Anda akan menerima notifikasi via email atau SMS ketika polis telah disetujui dan aktif.',
    ),
    FAQItem(
      category: 'Polis',
      question: 'Apakah saya bisa mengubah jenis polis setelah membeli?',
      answer:
          'Anda dapat mengubah paket polis sesuai kebutuhan dengan menghubungi tim customer service kami melalui aplikasi atau menelepon hotline. Perubahan akan berlaku pada tanggal pembaruan yang Anda tentukan.',
    ),
    FAQItem(
      category: 'Polis',
      question: 'Bagaimana cara memperpanjang polis asuransi?',
      answer:
          'Polis akan diperpanjang otomatis jika Anda mengaktifkan fitur auto-renewal. Jika tidak, Anda akan menerima notifikasi 30 hari sebelum masa berlaku habis. Anda dapat memperpanjang melalui menu "Polis Saya" di aplikasi.',
    ),
    FAQItem(
      category: 'Polis',
      question: 'Apakah saya bisa membatalkan polis dan mendapat refund?',
      answer:
          'Ya, Anda dapat membatalkan polis dalam masa cooling-off period (14 hari sejak pembelian) dan mendapat refund penuh. Setelah periode tersebut, pembatalan akan dikenakan biaya administrasi sesuai ketentuan yang berlaku.',
    ),
    FAQItem(
      category: 'Polis',
      question: 'Apa saja manfaat yang didapat dari polis asuransi Learra?',
      answer:
          'Manfaat bervariasi tergantung jenis polis. Asuransi Jiwa memberikan santunan meninggal dunia, Asuransi Kesehatan menanggung biaya rawat inap dan rawat jalan, sedangkan Asuransi Mobil menanggung kerusakan dan kehilangan kendaraan.',
    ),
    FAQItem(
      category: 'Akun',
      question: 'Bagaimana cara membuat akun di Learra?',
      answer:
          'Unduh aplikasi Learra, ketuk "Daftar", masukkan email dan nomor telepon Anda, buat password yang kuat, dan verifikasi email Anda. Akun siap digunakan setelah verifikasi selesai.',
    ),
    FAQItem(
      category: 'Akun',
      question: 'Saya lupa password, bagaimana cara reset?',
      answer:
          'Klik "Lupa Password" di layar login, masukkan email terdaftar, dan ikuti link reset yang dikirim ke email Anda. Buat password baru dan login kembali dengan kredensial terbaru.',
    ),
    FAQItem(
      category: 'Akun',
      question: 'Apakah data pribadi saya aman di aplikasi Learra?',
      answer:
          'Ya, kami menggunakan enkripsi tingkat bank dan protokol keamanan standar internasional untuk melindungi data Anda. Semua informasi pribadi tidak akan dibagikan kepada pihak ketiga tanpa persetujuan.',
    ),
    FAQItem(
      category: 'Akun',
      question: 'Bagaimana cara mengubah informasi profil saya?',
      answer:
          'Buka menu "Profil" di aplikasi, pilih "Edit Profil", lalu ubah informasi yang diperlukan seperti nama, alamat, atau nomor telepon. Jangan lupa klik "Simpan" setelah selesai melakukan perubahan.',
    ),
    FAQItem(
      category: 'Klaim',
      question: 'Bagaimana cara mengajukan klaim asuransi?',
      answer:
          'Buka aplikasi Learra, masuk ke menu "Klaim", pilih polis yang ingin diklaim, isi form pengajuan, dan upload dokumen pendukung (seperti bukti medis atau laporan kerusakan). Tim kami akan memeriksa dalam 1-3 hari kerja.',
    ),
    FAQItem(
      category: 'Klaim',
      question:
          'Dokumen apa saja yang diperlukan untuk klaim asuransi kesehatan?',
      answer:
          'Anda perlu menyiapkan: kartu identitas, kartu polis asuransi, bukti pembayaran medis (kwitansi/invoice), laporan medis dokter, resep obat, dan bukti transfer biaya kesehatan jika ada.',
    ),
    FAQItem(
      category: 'Klaim',
      question: 'Berapa lama proses persetujuan dan pencairan klaim?',
      answer:
          'Proses verifikasi klaim memakan waktu 1-3 hari kerja. Setelah disetujui, dana akan ditransfer ke rekening Anda dalam 5-7 hari kerja. Anda dapat memantau status klaim di menu "Riwayat Klaim" di aplikasi.',
    ),
    FAQItem(
      category: 'Klaim',
      question: 'Apa yang harus dilakukan jika klaim saya ditolak?',
      answer:
          'Jika klaim ditolak, Anda akan menerima penjelasan lengkap mengenai alasan penolakan. Anda dapat mengajukan banding dengan melengkapi dokumen tambahan atau menghubungi customer service untuk klarifikasi lebih lanjut.',
    ),
    FAQItem(
      category: 'Klaim',
      question: 'Bisakah saya melacak status klaim secara real-time?',
      answer:
          'Ya, Anda dapat melacak status klaim kapan saja melalui menu "Riwayat Klaim" di aplikasi. Status akan diperbarui secara otomatis setiap ada progress dari tim verifikasi kami.',
    ),
    FAQItem(
      category: 'Klaim',
      question: 'Apakah saya bisa menambah dokumen setelah mengajukan klaim?',
      answer:
          'Ya, Anda dapat menambahkan dokumen pendukung tambahan melalui menu detail klaim. Tim verifikasi akan meninjau ulang klaim Anda setelah dokumen baru diunggah.',
    ),
    FAQItem(
      category: 'Pembayaran',
      question: 'Metode pembayaran apa saja yang tersedia?',
      answer:
          'Learra menerima pembayaran melalui transfer bank, kartu kredit, e-wallet (GCash, Dana, OVO), dan cicilan. Pilih metode yang paling sesuai saat checkout.',
    ),
    FAQItem(
      category: 'Pembayaran',
      question: 'Bisakah saya mengatur pembayaran otomatis untuk premi?',
      answer:
          'Ya, Anda dapat mengaktifkan fitur auto-debit untuk pembayaran premi bulanan atau tahunan. Ini memastikan polis tetap aktif tanpa khawatir ketinggalan tanggal jatuh tempo.',
    ),
    FAQItem(
      category: 'Pembayaran',
      question: 'Apa yang harus dilakukan jika pembayaran gagal?',
      answer:
          'Jika pembayaran gagal, pastikan saldo atau limit kartu kredit Anda mencukupi. Anda dapat mencoba metode pembayaran lain atau menghubungi customer service jika masalah berlanjut. Pembayaran dapat diulang dalam 24 jam tanpa kehilangan data.',
    ),
    FAQItem(
      category: 'Pembayaran',
      question: 'Berapa lama proses refund jika saya membatalkan polis?',
      answer:
          'Proses refund memakan waktu 7-14 hari kerja setelah pembatalan disetujui. Dana akan dikembalikan ke rekening atau metode pembayaran yang sama dengan saat pembelian polis.',
    ),
    FAQItem(
      category: 'Lainnya',
      question: 'Bagaimana cara menghubungi customer service Learra?',
      answer:
          'Anda dapat menghubungi kami melalui: Live Chat di aplikasi (24/7), email support@learra.com, atau telepon hotline 1500-LEARRA (1500-532772) tersedia Senin-Jumat 08:00-17:00 WIB.',
    ),
    FAQItem(
      category: 'Lainnya',
      question: 'Apakah ada biaya tersembunyi dalam produk asuransi Learra?',
      answer:
          'Tidak ada biaya tersembunyi. Semua biaya akan dijelaskan dengan transparan sebelum Anda membeli polis, termasuk premi bulanan, biaya admin (jika ada), dan benefit yang Anda dapatkan.',
    ),
    FAQItem(
      category: 'Lainnya',
      question: 'Apakah saya akan mendapat notifikasi untuk pembayaran premi?',
      answer:
          'Ya, Anda akan menerima notifikasi melalui aplikasi, email, dan SMS 7 hari sebelum tanggal jatuh tempo pembayaran premi. Pastikan notifikasi aplikasi sudah diaktifkan di pengaturan perangkat Anda.',
    ),
    FAQItem(
      category: 'Lainnya',
      question: 'Bagaimana Learra menjaga keamanan transaksi saya?',
      answer:
          'Kami menggunakan teknologi enkripsi SSL 256-bit, autentikasi dua faktor (2FA), dan sistem monitoring 24/7 untuk melindungi setiap transaksi. Semua data keuangan Anda tersimpan dengan aman sesuai standar PCI-DSS.',
    ),
    FAQItem(
      category: 'Lainnya',
      question: 'Apakah aplikasi Learra tersedia untuk iOS dan Android?',
      answer:
          'Ya, aplikasi Learra tersedia untuk perangkat iOS (App Store) dan Android (Google Play Store). Anda dapat mengunduh aplikasi secara gratis dan mengakses semua fitur di kedua platform.',
    ),
  ];

  Widget _buildFAQCategory(String category, List<FAQItem> items) {
    final isCategoryExpanded = expandedCategories.contains(category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (expandedCategories.contains(category)) {
                    expandedCategories.remove(category);
                  } else {
                    expandedCategories.add(category);
                  }
                });
              },
              child: Container(
                width: double.infinity,
                color: Colors.transparent,
                padding: const EdgeInsets.all(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isCategoryExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.expand_more,
                        color: Color(0xFF9CA3AF),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isCategoryExpanded) ...[
              Container(height: 1, color: const Color(0xFFE5E7EB)),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final uniqueKey = '${category}_$index';
                    final isExpanded = expandedQuestionIndex == uniqueKey;

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == items.length - 1 ? 0 : 8,
                      ),
                      child: FAQCard(
                        item: item,
                        isExpanded: isExpanded,
                        onTap: () {
                          setState(() {
                            expandedQuestionIndex = isExpanded
                                ? null
                                : uniqueKey;
                          });
                        },
                      ),
                    );
                  }),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<FAQItem>> groupedFAQ = {};
    for (var item in faqItems) {
      if (!groupedFAQ.containsKey(item.category)) {
        groupedFAQ[item.category] = [];
      }
      groupedFAQ[item.category]!.add(item);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Bantuan & FAQ',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pertanyaan Umum',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Temukan jawaban atas pertanyaan Anda tentang produk dan layanan Learra',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          ...groupedFAQ.entries
              .map((entry) => _buildFAQCategory(entry.key, entry.value))
              // ignore: unnecessary_to_list_in_spreads
              .toList(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'TIM PENGEMBANG',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Column(
            children: developers
                .map((dev) => DeveloperCard(developer: dev))
                .toList(),
          ),
          const SizedBox(height: 24),
          const ContactBox(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
