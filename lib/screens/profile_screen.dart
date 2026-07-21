import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../models/mock_database.dart';
import '../models/family_member.dart';
import '../models/user_profile.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';
import 'ambil_antrian_screen.dart';
import 'riwayat_screen.dart';


class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserProfile? user = MockDatabase.currentUser;

    if (user == null) {
      // In a real app, you might want to redirect to login or show a placeholder
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Silakan masuk terlebih dahulu'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, WelcomeScreen.routeName),
                child: const Text('Ke halaman awal'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: navigate ke menu edit profile
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _ProfileHeaderCard(user: user),
            const SizedBox(height: 24),
            const _SectionLabel('INFORMASI AKUN'),
            const SizedBox(height: 12),
            _AccountInfoCard(user: user),
            const SizedBox(height: 24),
            const _SectionLabel('ANGGOTA KELUARGA'),
            const SizedBox(height: 12),
            _FamilyMembersCard(members: user.familyMembers),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                // TODO: navigate ke tambah family
              },
              child: const Text('+ Tambah anggota keluarga'),
            ),
            const SizedBox(height: 20),
            _LogoutRow(
              onTap: () => _handleLogout(context),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _ProfileBottomNav(),
    );
  }
}

Future<void> _handleLogout(BuildContext context) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Keluar dari akun?'),
      content: const Text(
        'Anda perlu masuk kembali untuk mengambil antrian, '
            'melihat status, dan riwayat kunjungan.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFD9534F)),
          child: const Text('Keluar'),
        ),
      ],
    ),
  );

  if (confirmed != true) return;
  if (!context.mounted) return;

  // Brief loading state while the (mock) sign-out completes.
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(color: AppColors.primaryBlue),
    ),
  );

  // sign-out call — clear stored tokens/session
  MockDatabase.currentUser = null;
  await Future.delayed(const Duration(milliseconds: 600));

  if (!context.mounted) return;
  Navigator.of(context, rootNavigator: true).pop(); // dismiss the loader
  Navigator.pushNamedAndRemoveUntil(
    context,
    WelcomeScreen.routeName,
        (route) => false,
  );
}

class _ProfileHeaderCard extends StatelessWidget {
  final UserProfile user;
  const _ProfileHeaderCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.activeQueueBg,
            child: Text(
              user.initials,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (user.isVerified) const _VerifiedBadge(),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'NIK: ${user.nikMasked}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'No. RM: ${user.noRm}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
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

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFD9F0DE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, size: 13, color: AppColors.successGreen),
          const SizedBox(width: 4),
          Text(
            'Terverifikasi',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.successGreen,
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

class _AccountInfoCard extends StatelessWidget {
  final UserProfile user;
  const _AccountInfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _InfoTile(
            icon: Icons.phone_iphone,
            label: 'Nomor HP',
            value: user.phoneMasked,
            onTap: () {
              // TODO: navigate ke menu ganti nomor telp
            },
          ),
          const Divider(height: 1, indent: 64, endIndent: 16),
          _InfoTile(
            icon: Icons.mail_outline,
            label: 'Email',
            value: user.email,
            onTap: () {
              // TODO: navigate ke menu ganti email
            },
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
              child: Icon(icon, size: 17, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _FamilyMembersCard extends StatelessWidget {
  final List<FamilyMember> members;
  const _FamilyMembersCard({required this.members});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          for (int i = 0; i < members.length; i++) ...[
            _FamilyMemberTile(member: members[i]),
            if (i != members.length - 1)
              const Divider(height: 1, indent: 64, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

class _FamilyMemberTile extends StatelessWidget {
  final FamilyMember member;
  const _FamilyMemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: navigate ke menu detail family
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: member.avatarColor,
              child: Text(
                member.initials,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    member.relation,
                    style: const TextStyle(
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
    );
  }
}

class _LogoutRow extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const Color red = Color(0xFFD9534F);
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
                decoration: BoxDecoration(
                  color: red.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.power_settings_new,
                    size: 17, color: red),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Keluar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: red,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: red),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom navigation used on the Profile screen, with "Profil" active.
class _ProfileBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.textSecondary,
      showUnselectedLabels: true,
      onTap: (index) {
        if (index == 3) return;
        if (index == 0) {
          Navigator.pushNamed(context, HomeScreen.routeName);
        } else if (index == 1) {
          Navigator.pushNamed(context, AmbilAntrianScreen.routeName);
        } else if (index == 2) {
          Navigator.pushNamed(context, RiwayatScreen.routeName);
        }
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), label: 'Beranda'),
        BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined), label: 'Antrian'),
        BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined), label: 'Riwayat'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }
}