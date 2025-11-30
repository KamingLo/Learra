import 'package:flutter/material.dart';

class TermsAndConditionsDialog extends StatefulWidget {
  const TermsAndConditionsDialog({super.key});

  @override
  State<TermsAndConditionsDialog> createState() =>
      _TermsAndConditionsDialogState();
}

class _TermsAndConditionsDialogState extends State<TermsAndConditionsDialog> {
  bool _hasScrolledToBottom = false;
  bool _agreedToTerms = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      if (currentScroll >= maxScroll * 0.9 && !_hasScrolledToBottom) {
        setState(() {
          _hasScrolledToBottom = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade600, Colors.green.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Syarat & Ketentuan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Mohon baca dengan teliti',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      icon: Icons.description_outlined,
                      title: '1. Ketentuan Umum',
                      content:
                          'Dengan mengajukan polis asuransi ini, Anda menyetujui untuk terikat dengan syarat dan ketentuan yang berlaku. Polis ini merupakan perjanjian yang sah antara Anda sebagai tertanggung dengan perusahaan asuransi.',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      icon: Icons.verified_user_outlined,
                      title: '2. Kewajiban Tertanggung',
                      content:
                          'Tertanggung wajib memberikan informasi yang benar dan lengkap. Pemberian informasi yang tidak benar dapat mengakibatkan pembatalan polis atau penolakan klaim. Tertanggung juga wajib membayar premi tepat waktu sesuai kesepakatan.',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      icon: Icons.account_balance_wallet_outlined,
                      title: '3. Pembayaran Premi',
                      content:
                          'Premi yang tertera adalah estimasi awal dan dapat berubah sesuai dengan perhitungan akhir sistem. Keterlambatan pembayaran dapat mengakibatkan penangguhan atau pembatalan polis.',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      icon: Icons.assignment_outlined,
                      title: '4. Pengajuan Klaim',
                      content:
                          'Klaim dapat diajukan sesuai dengan ketentuan polis yang berlaku. Tertanggung wajib melaporkan kejadian yang diasuransikan maksimal 3x24 jam.',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      icon: Icons.cancel_outlined,
                      title: '5. Pengecualian',
                      content:
                          'Polis tidak menanggung kerugian akibat: perang, huru-hara, bencana nuklir, kesengajaan tertanggung, atau hal-hal yang dikecualikan secara spesifik dalam polis. Harap membaca polis dengan teliti untuk mengetahui pengecualian lengkap.',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      icon: Icons.update_outlined,
                      title: '6. Perubahan & Pembatalan',
                      content:
                          'Perusahaan berhak mengubah syarat dan ketentuan dengan pemberitahuan terlebih dahulu. Pengembalian premi (jika ada) akan disesuaikan dengan masa berlaku polis.',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      icon: Icons.privacy_tip_outlined,
                      title: '7. Perlindungan Data',
                      content:
                          'Data pribadi Anda akan dijaga kerahasiaannya dan hanya digunakan untuk keperluan administrasi polis dan klaim. Data tidak akan dibagikan kepada pihak ketiga tanpa persetujuan Anda kecuali diwajibkan oleh hukum.',
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.amber.shade800,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Dengan menyetujui syarat dan ketentuan ini, Anda menyatakan telah membaca, memahami, dan menerima seluruh isi dokumen ini.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber.shade900,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Column(
                children: [
                  AnimatedOpacity(
                    opacity: _hasScrolledToBottom ? 1.0 : 0.4,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _agreedToTerms
                            ? Colors.green.shade50
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _agreedToTerms
                              ? Colors.green.shade300
                              : Colors.grey.shade300,
                          width: _agreedToTerms ? 2 : 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Transform.scale(
                            scale: 1.2,
                            child: Checkbox(
                              value: _agreedToTerms,

                              onChanged: _hasScrolledToBottom
                                  ? (value) {
                                      setState(() {
                                        _agreedToTerms = value ?? false;
                                      });
                                    }
                                  : null,
                              activeColor: Colors.green.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: _hasScrolledToBottom
                                  ? () {
                                      setState(() {
                                        _agreedToTerms = !_agreedToTerms;
                                      });
                                    }
                                  : null,
                              child: Text(
                                'Saya telah membaca dan menyetujui seluruh Syarat & Ketentuan di atas',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _hasScrolledToBottom
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _agreedToTerms
                          ? () => Navigator.of(context).pop(true)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _agreedToTerms
                            ? Colors.green.shade600
                            : Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        elevation: _agreedToTerms ? 2 : 0,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_agreedToTerms)
                            Padding(padding: const EdgeInsets.only(right: 8)),
                          Text(
                            _agreedToTerms
                                ? 'Setuju & Lanjutkan'
                                : 'Setuju & Lanjutkan',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.green.shade700, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
