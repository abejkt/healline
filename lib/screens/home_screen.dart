import 'package:flutter/material.dart';
import '../utils/date_formatter.dart';
import '../services/auth_service.dart';
import '../services/queue_service.dart';
import '../models/active_queue_status.dart';
import '../themes/app_theme.dart';
import 'ambil_antrian_screen.dart';
import 'status_antrian_screen.dart';
import 'riwayat_screen.dart';
import 'profile_screen.dart';


class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final QueueService _queueService = QueueService();
  
  String _userName = AuthService.currentUser?.name ?? 'Tamu';
  final String _dateLabel = DateFormatterId.formatFullDateId(DateTime.now());
  
  String? _queueNumber;
  String? _queueStatus;
  String? _queueDetail;
  bool _isLoadingQueue = false;

  @override
  void initState() {
    super.initState();
    _fetchActiveQueue();
  }

  Future<void> _fetchActiveQueue() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    setState(() {
      _isLoadingQueue = true;
      _userName = user.name;
    });

    try {
      final upcoming = await _queueService.fetchUpcomingQueues(user.id);
      
      if (upcoming.isNotEmpty) {
        final ticket = upcoming.first;
        final status = await _queueService.fetchActiveQueue(ticket.ticketNumber);
        
        if (status != null) {
          setState(() {
            _queueNumber = status.ticketNumber;
            _queueStatus = status.statusLabel;
            _queueDetail = '${status.poliName} · ${status.etaLabel} · ${status.remainingCount} antrian lagi';
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching active queue on home: $e');
    } finally {
      if (mounted) setState(() => _isLoadingQueue = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchActiveQueue,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              _Header(userName: _userName, dateLabel: _dateLabel),
              const SizedBox(height: 20),
              if (_isLoadingQueue)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
              else if (_queueNumber != null)
                _ActiveQueueCard(
                  queueNumber: _queueNumber!,
                  status: _queueStatus ?? '-',
                  detail: _queueDetail ?? '',
                )
              else
                _NoActiveQueueCard(),
              const SizedBox(height: 24),
              const _SectionLabel('MENU UTAMA'),
              const SizedBox(height: 12),
              _MainMenuGrid(),
              const SizedBox(height: 24),
              const _SectionLabel('INFO RUMAH SAKIT'),
              const SizedBox(height: 12),
              const _HospitalInfoCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;
          if (index == 1) {
            Navigator.pushNamed(context, AmbilAntrianScreen.routeName);
          } else if (index == 2) {
            Navigator.pushNamed(context, RiwayatScreen.routeName);
          } else if (index == 3) {
            Navigator.pushNamed(context, ProfileScreen.routeName);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textSecondary,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number_outlined), label: 'Antrian'),
          BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _NoActiveQueueCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.confirmation_number_outlined, size: 40, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          const Text(
            'Tidak ada antrian aktif',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ambil nomor antrian untuk hari ini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, AmbilAntrianScreen.routeName),
              child: const Text('Ambil Antrian'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String userName;
  final String dateLabel;

  const _Header({required this.userName, required this.dateLabel});

  @override
  Widget build(BuildContext context) {
    final String greeting = DateFormatterId.getTimeGreeting();
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $userName',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dateLabel,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: const Icon(
            Icons.notifications_none_outlined,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
      ],
    );
  }
}

class _ActiveQueueCard extends StatelessWidget {
  final String queueNumber;
  final String status;
  final String detail;

  const _ActiveQueueCard({
    required this.queueNumber,
    required this.status,
    required this.detail,
  });

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
            'Antrian aktif hari ini',
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
                queueNumber,
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
                  status,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.statusBadgeText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.activeQueueText,
            ),
          ),
        ],
      ),
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

class _MainMenuGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuItemData(
        icon: Icons.badge_outlined,
        label: 'Ambil antrian',
          onTap: () =>
              Navigator.pushNamed(context, AmbilAntrianScreen.routeName),
      ),
      _MenuItemData(
        icon: Icons.watch_later_outlined,
        label: 'Status antrian',
        onTap: () =>
            Navigator.pushNamed(context, StatusAntrianScreen.routeName),
      ),
      _MenuItemData(
        icon: Icons.description_outlined,
        label: 'Riwayat',
        onTap: () =>
            Navigator.pushNamed(context, RiwayatScreen.routeName),
      ),
      _MenuItemData(
        icon: Icons.person_outline,
        label: 'Profil',
        onTap: () =>
            Navigator.pushNamed(context, ProfileScreen.routeName),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _MenuCard(icon: item.icon, label: item.label, onTap: item.onTap);
      },
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItemData(
      {required this.icon, required this.label, required this.onTap});
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuCard(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardWhite,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.activeQueueBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primaryBlue, size: 18),
              ),
              const Spacer(),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HospitalInfoCard extends StatelessWidget {
  const _HospitalInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const _InfoRow(
            icon: Icons.access_time_outlined,
            iconBg: AppColors.statusBadgeBg,
            iconColor: AppColors.statusBadgeText,
            title: 'Jam operasional',
            subtitle: 'Senin–Sabtu 07:00–21:00',
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          const _InfoRow(
            icon: Icons.call_outlined,
            iconBg: Color(0xFFD9F0DE),
            iconColor: AppColors.successGreen,
            title: 'Call center',
            subtitle: '021-5550-1234',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _InfoRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
