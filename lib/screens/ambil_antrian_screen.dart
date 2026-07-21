import 'package:flutter/material.dart';
import '../utils/date_formatter.dart';
import '../services/doctor_service.dart';
import '../services/patient_service.dart';
import '../models/mock_database.dart';
import '../models/doctor.dart';
import '../models/patient.dart';
import '../models/poli.dart';
import '../themes/app_theme.dart';
import 'home_screen.dart';
import 'tiket_antrian_screen.dart';
import 'riwayat_screen.dart';
import 'profile_screen.dart';


class AmbilAntrianScreen extends StatefulWidget {
  static const routeName = '/ambil-antrian';

  const AmbilAntrianScreen({super.key});

  @override
  State<AmbilAntrianScreen> createState() => _AmbilAntrianScreenState();
}

class _AmbilAntrianScreenState extends State<AmbilAntrianScreen> {
  late String _selectedPoliId;
  String? _selectedDoctorId;
  late DateTime _selectedDate;
  late Patient _selectedPatient;

  final DoctorService _doctorService = DoctorService();
  final PatientService _patientService = PatientService();
  List<Doctor> _doctors = [];
  List<Patient> _availablePatients = [];
  bool _isLoadingDoctors = false;

  @override
  void initState() {
    super.initState();
    _selectedPoliId = MockDatabase.polis.first.id;
    
    // Ensure initial date is not before today to avoid date picker crash
    final now = DateTime.now();
    _selectedDate = MockDatabase.nextVisitDate.isBefore(now) 
        ? now.add(const Duration(days: 1)) 
        : MockDatabase.nextVisitDate;

    // Load patients from the current logged-in user
    final user = MockDatabase.currentUser;
    if (user != null) {
      _availablePatients = _patientService.getPatients(user, user.familyMembers);
    } else {
      // Fallback for demo if not logged in
      _availablePatients = MockDatabase.patients;
    }
    
    _selectedPatient = _availablePatients.isNotEmpty 
        ? _availablePatients.first 
        : const Patient(id: 'guest', name: 'Tamu', relationLabel: '');

    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    setState(() {
      _isLoadingDoctors = true;
      _selectedDoctorId = null;
    });

    try {
      final doctors = await _doctorService.fetchDoctors(_selectedPoliId);
      setState(() {
        _doctors = doctors;
        final available = doctors.where((d) => d.isAvailable).toList();
        _selectedDoctorId = available.isNotEmpty ? available.first.id : null;
      });
    } catch (e) {
      // Handle error (e.g., show SnackBar)
      debugPrint('Error fetching doctors: $e');
    } finally {
      setState(() => _isLoadingDoctors = false);
    }
  }

  void _onPoliSelected(String poliId) {
    setState(() {
      _selectedPoliId = poliId;
    });
    _fetchDoctors();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickPatient() async {
    final result = await showModalBottomSheet<Patient>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih pasien',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                for (final patient in _availablePatients)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(patient.displayName),
                    trailing: patient.id == _selectedPatient.id
                        ? const Icon(Icons.check_circle,
                        color: AppColors.primaryBlue)
                        : null,
                    onTap: () => Navigator.pop(sheetContext, patient),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (result != null) {
      setState(() => _selectedPatient = result);
    }
  }

  bool get _canConfirm => _selectedDoctorId != null;

  void _confirm() {
    if (!_canConfirm) return;
    // TODO: call the real "take a queue number" API using the selections
    // above, then navigate using the ticket it returns.
    Navigator.pushNamed(context, TiketAntrianScreen.routeName);
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
        title: const Text('Ambil antrian'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const _SectionLabel('PILIH POLIKLINIK'),
            const SizedBox(height: 12),
            _PoliGrid(
              selectedPoliId: _selectedPoliId,
              onSelected: _onPoliSelected,
            ),
            const SizedBox(height: 24),
            const _SectionLabel('TANGGAL KUNJUNGAN'),
            const SizedBox(height: 12),
            _DateField(
              dateLabel: DateFormatterId.formatDateWithWeekdayId(_selectedDate),
              onTap: _pickDate,
            ),
            const SizedBox(height: 24),
            const _SectionLabel('PILIH DOKTER'),
            const SizedBox(height: 12),
            if (_isLoadingDoctors)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              _DoctorListCard(
                doctors: _doctors,
                selectedDoctorId: _selectedDoctorId,
                onSelected: (id) => setState(() => _selectedDoctorId = id),
              ),
            const SizedBox(height: 24),
            const _SectionLabel('PASIEN'),
            const SizedBox(height: 12),
            _PatientField(
              patientLabel: _selectedPatient.displayName,
              onTap: _pickPatient,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _canConfirm ? _confirm : null,
              child: const Text('Konfirmasi & ambil nomor'),
            ),
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

class _PoliGrid extends StatelessWidget {
  final String selectedPoliId;
  final ValueChanged<String> onSelected;

  const _PoliGrid({required this.selectedPoliId, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: MockDatabase.polis.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.6,
      ),
      itemBuilder: (context, index) {
        final Poli poli = MockDatabase.polis[index];
        final bool isSelected = poli.id == selectedPoliId;
        return _PoliCard(
          poli: poli,
          isSelected: isSelected,
          onTap: () => onSelected(poli.id),
        );
      },
    );
  }
}

class _PoliCard extends StatelessWidget {
  final Poli poli;
  final bool isSelected;
  final VoidCallback onTap;

  const _PoliCard({
    required this.poli,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.activeQueueBg : AppColors.cardWhite,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : Colors.transparent,
              width: 1.4,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : AppColors.inputFill,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  poli.icon,
                  size: 16,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  poli.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String dateLabel;
  final VoidCallback onTap;

  const _DateField({required this.dateLabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                dateLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _DoctorListCard extends StatelessWidget {
  final List<Doctor> doctors;
  final String? selectedDoctorId;
  final ValueChanged<String> onSelected;

  const _DoctorListCard({
    required this.doctors,
    required this.selectedDoctorId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (doctors.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          'Belum ada dokter untuk poliklinik ini.',
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
          for (int i = 0; i < doctors.length; i++) ...[
            _DoctorTile(
              doctor: doctors[i],
              isSelected: doctors[i].id == selectedDoctorId,
              onTap: () => onSelected(doctors[i].id),
            ),
            if (i != doctors.length - 1)
              const Divider(height: 1, indent: 64, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

class _DoctorTile extends StatelessWidget {
  final Doctor doctor;
  final bool isSelected;
  final VoidCallback onTap;

  const _DoctorTile({
    required this.doctor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = doctor.isAvailable;
    final Color statusBg = isAvailable
        ? const Color(0xFFD9F0DE)
        : const Color(0xFFF7DEDC);
    final Color statusText =
    isAvailable ? AppColors.successGreen : const Color(0xFFC0564F);

    return Opacity(
      opacity: isAvailable ? 1 : 0.55,
      child: InkWell(
        onTap: isAvailable ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.activeQueueBg : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: doctor.avatarColor,
                child: Text(
                  doctor.initials,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctor.quotaLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  doctor.availability.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientField extends StatelessWidget {
  final String patientLabel;
  final VoidCallback onTap;

  const _PatientField({required this.patientLabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                patientLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

Widget buildAntrianBottomNav(BuildContext context, {required int currentIndex}) {
  return BottomNavigationBar(
    currentIndex: currentIndex,
    type: BottomNavigationBarType.fixed,
    selectedItemColor: AppColors.primaryBlue,
    unselectedItemColor: AppColors.textSecondary,
    showUnselectedLabels: true,
    onTap: (index) {
      if (index == currentIndex) return;
      switch (index) {
        case 0:
          Navigator.pushNamedAndRemoveUntil(
              context, HomeScreen.routeName, (route) => false);
          break;
        case 1:
          Navigator.pushNamedAndRemoveUntil(
              context, AmbilAntrianScreen.routeName, (route) => false);
          break;
        case 2:
          Navigator.pushReplacementNamed(context, RiwayatScreen.routeName);
          break;
        case 3:
          Navigator.pushReplacementNamed(context, ProfileScreen.routeName);
          break;
      }
    },
    items: [
      const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined), label: 'Beranda'),
      BottomNavigationBarItem(
        icon: Icon(currentIndex == 1
            ? Icons.confirmation_number
            : Icons.confirmation_number_outlined),
        label: 'Antrian',
      ),
      const BottomNavigationBarItem(
          icon: Icon(Icons.article_outlined), label: 'Riwayat'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline), label: 'Profil'),
    ],
  );
}