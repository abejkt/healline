import 'package:flutter/material.dart';
import '../utils/date_formatter.dart';
import '../models/visit.dart';
import '../services/visit_service.dart';
import '../themes/app_theme.dart';
import 'home_screen.dart';
import 'ambil_antrian_screen.dart';
import 'profile_screen.dart';

class RiwayatScreen extends StatefulWidget {
  static const routeName = '/riwayat';

  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  static const String _allFilter = 'Semua';
  String _selectedFilter = _allFilter;

  final VisitService _visitService = VisitService();
  List<Visit> _allVisits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVisits();
  }

  Future<void> _fetchVisits() async {
    setState(() => _isLoading = true);
    try {
      final visits = await _visitService.fetchVisits();
      setState(() {
        _allVisits = visits;
      });
    } catch (e) {
      debugPrint('Error fetching visits: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Visit> get _filteredVisits {
    if (_selectedFilter == _allFilter) return _allVisits;
    return _allVisits
        .where((v) => v.year.toString() == _selectedFilter)
        .toList();
  }

  List<String> get _availableYears {
    final years = _allVisits.map((v) => v.year.toString()).toSet().toList();
    years.sort((a, b) => b.compareTo(a)); // Sort years descending
    return years;
  }

  @override
  Widget build(BuildContext context) {
    final visits = _filteredVisits;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Riwayat kunjungan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchVisits,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _FilterChipsRow(
                    selected: _selectedFilter,
                    options: [_allFilter, ..._availableYears],
                    onSelected: (value) => setState(() => _selectedFilter = value),
                  ),
                  const SizedBox(height: 16),
                  _TotalVisitsBanner(count: visits.length),
                  const SizedBox(height: 16),
                  _VisitListCard(visits: visits),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: visits.isEmpty
                        ? null
                        : () {
                            // TODO: pre-fill antrian baru di riwayat kunjungan terakhir poli.
                          },
                    icon: const Icon(Icons.north_east, size: 18),
                    label: const Text('Daftar ulang kunjungan terakhir'),
                  ),
                  const SizedBox(height: 16),
                  _DownloadRecapRow(
                    onTap: () {
                      // TODO: export semua riwayat kunjungan ke PDF.
                    },
                  ),
                ],
              ),
      ),
      bottomNavigationBar: _RiwayatBottomNav(),
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  final String selected;
  final List<String> options;
  final ValueChanged<String> onSelected;

  const _FilterChipsRow({
    required this.selected,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final option in options) ...[
            _FilterChip(
              label: option,
              isSelected: option == selected,
              onTap: () => onSelected(option),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.activeQueueBg : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.activeQueueBg : AppColors.inputBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _TotalVisitsBanner extends StatelessWidget {
  final int count;
  const _TotalVisitsBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.activeQueueBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'Total $count kunjungan',
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.activeQueueText,
        ),
      ),
    );
  }
}

class _VisitListCard extends StatelessWidget {
  final List<Visit> visits;
  const _VisitListCard({required this.visits});

  @override
  Widget build(BuildContext context) {
    if (visits.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text(
            'Belum ada kunjungan pada periode ini.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
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
          for (int i = 0; i < visits.length; i++) ...[
            _VisitTile(visit: visits[i]),
            if (i != visits.length - 1)
              const Divider(height: 1, indent: 64, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

class _VisitTile extends StatelessWidget {
  final Visit visit;
  const _VisitTile({required this.visit});

  @override
  Widget build(BuildContext context) {
    final bool isSelesai = visit.status == VisitStatus.selesai;
    final Color statusBg =
        isSelesai ? const Color(0xFFD9F0DE) : AppColors.statusBadgeBg;
    final Color statusText =
        isSelesai ? AppColors.successGreen : AppColors.statusBadgeText;

    return InkWell(
      onTap: () {
        // TODO: navigate to visit detail screen.
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFD9F0DE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelesai ? Icons.check : Icons.close,
                size: 18,
                color: AppColors.successGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${visit.poli} · ${visit.doctorName}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${DateFormatterId.formatDateId(visit.date)} · ${visit.queueCode}',
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
                color: statusBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                visit.status.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusText,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _DownloadRecapRow extends StatelessWidget {
  final VoidCallback onTap;
  const _DownloadRecapRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardWhite,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.inputFill,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.description_outlined,
                    size: 17, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unduh rekap kunjungan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Ekspor semua riwayat ke PDF',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom navigation used on the Riwayat screen, with "Riwayat" active.
class _RiwayatBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.textSecondary,
      showUnselectedLabels: true,
      onTap: (index) {
        if (index == 2) return;
        if (index == 0) {
          Navigator.pushNamed(context, HomeScreen.routeName);
        } else if (index == 1) {
          Navigator.pushNamed(context, AmbilAntrianScreen.routeName);
        } else if (index == 3) {
          Navigator.pushNamed(context, ProfileScreen.routeName);
        }
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), label: 'Beranda'),
        BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined), label: 'Antrian'),
        BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Riwayat'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Profil'),
      ],
    );
  }
}
