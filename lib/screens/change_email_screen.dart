import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class ChangeEmailScreen extends StatefulWidget {
  static const routeName = '/change-email';

  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final _emailController = TextEditingController();
  final _userService = UserService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = AuthService.currentUser?.email ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateEmail() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    final newEmail = _emailController.text.trim();
    
    if (newEmail == user.email) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email baru tidak boleh sama dengan email lama')),
      );
      return;
    }

    if (newEmail.isEmpty || !newEmail.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan alamat email yang valid')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _userService.updateEmail(user.id, newEmail);
      
      final updatedUser = await _userService.fetchUserProfile(user.id);
      AuthService.currentUser = updatedUser;

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email berhasil diperbarui')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui email: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ganti Email'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Email digunakan untuk mengirimkan notifikasi dan rekap riwayat kunjungan Anda.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              const Text(
                'EMAIL BARU',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'contoh@email.com',
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateEmail,
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
