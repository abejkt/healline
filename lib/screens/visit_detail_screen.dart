import 'package:flutter/material.dart';
import '../models/visit.dart';
import '../utils/date_formatter.dart';
import '../themes/app_theme.dart';

class VisitDetailScreen extends StatelessWidget {
  static const routeName = '/visit-detail';

  const VisitDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final visit = ModalRoute.of(context)!.settings.arguments as Visit;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Kunjungan'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusHeader(visit),
              const SizedBox(height: 24),
              _buildVisitInfoCard(visit),
              const SizedBox(height: 24),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader(Visit visit) {
    final bool isSelesai = visit.status == VisitStatus.selesai;
    final Color statusColor = isSelesai ? AppColors.successGreen : AppColors.statusBadgeText;
    
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelesai ? const Color(0xFFD9F0DE) : AppColors.statusBadgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              visit.status.label.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            visit.ticketNumber,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const Text(
            'Nomor Tiket Antrian',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitInfoCard(Visit visit) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Poliklinik', visit.poli),
          const Divider(height: 32),
          _buildInfoRow('Dokter', visit.doctorName),
          const Divider(height: 32),
          _buildInfoRow('Tanggal', DateFormatterId.formatFullDateId(visit.date)),
          const Divider(height: 32),
          _buildInfoRow('Waktu', '${visit.date.hour.toString().padLeft(2, '0')}:${visit.date.minute.toString().padLeft(2, '0')} WIB'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Download PDF logic
          },
          icon: const Icon(Icons.file_download_outlined),
          label: const Text('Unduh Rekap Medis (PDF)'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Kembali'),
        ),
      ],
    );
  }
}
