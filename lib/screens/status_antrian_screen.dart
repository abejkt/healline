import 'package:flutter/material.dart';
import '../models/active_queue_status.dart';
import '../services/queue_service.dart';
import '../themes/app_theme.dart';
import 'home_screen.dart';
import 'ambil_antrian_screen.dart';

class StatusAntrianScreen extends StatefulWidget {
  static const routeName = '/status-antrian';

  const StatusAntrianScreen({super.key});

  @override
  State<StatusAntrianScreen> createState() => _StatusAntrianScreenState();
}

class _StatusAntrianScreenState extends State<StatusAntrianScreen> {
  final QueueService _queueService = QueueService();
  ActiveQueueStatus? _status;
  List<UpcomingQueue> _upcoming = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final status = await _queueService.fetchActiveQueue('A-042');
      final upcoming = await _queueService.fetchUpcomingQueues('user-albert');
      
      setState(() {
        _status = status;
        _upcoming = upcoming;
      });
    } catch (e) {
      debugPrint('Error fetching queue status: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan antrian ini?'),
        content: const Text(
          'Nomor antrian Anda akan dilepas dan diberikan kepada pasien '
              'berikutnya. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style:
            TextButton.styleFrom(foregroundColor: const Color(0xFFD9534F)),
            child: const Text('Ya, batalkan'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    // TODO: call the real "cancel queue" API here.
    Navigator.pushNamedAndRemoveUntil(
      context,
      HomeScreen.routeName,
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Status antrian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            if (_status != null) ...[
              _ActiveQueueStatusCard(status: _status!),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: open the live tracker / map view.
                      },
                      child: const Text('Pantau live'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _confirmCancel(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD9534F),
                        side: const BorderSide(color: Color(0xFFD9534F)),
                      ),
                      child: const Text('Batalkan'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            const _SectionLabel('ANTRIAN LAINNYA'),
            const SizedBox(height: 12),
            _UpcomingQueueCard(items: _upcoming),
            const SizedBox(height: 16),
            const _LiveTrackerRow(),
          ],
        ),
      ),
      bottomNavigationBar: buildAntrianBottomNav(context, currentIndex: 1),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _ActiveQueueStatusCard extends StatelessWidget {
  final ActiveQueueStatus status;
  const _ActiveQueueStatusCard({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.activeQueueBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Antrian aktif',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.activeQueueText,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                status.ticketNumber,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.statusBadgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.statusLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.statusBadgeText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${status.poliName} · ${status.doctorName}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.activeQueueText,
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: AppColors.primaryBlue.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatColumn(
                  value: status.calledNumberLabel,
                  label: 'Dipanggil',
                ),
              ),
              _StatDivider(),
              Expanded(
                child: _StatColumn(
                  value: '${status.remainingCount}',
                  label: 'Sisa antrian',
                ),
              ),
              _StatDivider(),
              Expanded(
                child: _StatColumn(
                  value: status.etaLabel,
                  label: 'Estimasi',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: status.progressPercent,
                    minHeight: 6,
                    backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${status.progressPercentLabel}% selesai',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.activeQueueText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.activeQueueText,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      color: AppColors.primaryBlue.withValues(alpha: 0.15),
    );
  }
}

class _UpcomingQueueCard extends StatelessWidget {
  final List<UpcomingQueue> items;
  const _UpcomingQueueCard({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          'Tidak ada antrian lain yang dijadwalkan.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _UpcomingQueueTile(item: items[i]),
            if (i != items.length - 1)
              const Divider(height: 1, indent: 16, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

class _UpcomingQueueTile extends StatelessWidget {
  final UpcomingQueue item;
  const _UpcomingQueueTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isAktif = item.status == UpcomingQueueStatus.aktif;
    final Color badgeBg =
    isAktif ? const Color(0xFFD9F0DE) : AppColors.activeQueueBg;
    final Color badgeText =
    isAktif ? AppColors.successGreen : AppColors.activeQueueText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.ticketNumber} · ${item.poliName}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.scheduleLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.status.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: badgeText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveTrackerRow extends StatelessWidget {
  const _LiveTrackerRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFD9F0DE),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.podcasts_outlined,
                size: 17, color: AppColors.successGreen),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live tracker aktif',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Notifikasi dikirim saat giliran Anda',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFD9F0DE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Aktif',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.successGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
