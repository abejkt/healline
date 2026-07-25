import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class ChangePhoneScreen extends StatefulWidget {
  static const routeName = '/change-phone';

  const ChangePhoneScreen({super.key});

  @override
  State<ChangePhoneScreen> createState() => _ChangePhoneScreenState();
}

class _ChangePhoneScreenState extends State<ChangePhoneScreen> {
  final _phoneController = TextEditingController();
  final _userService = UserService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController.text = AuthService.currentUser?.phoneMasked ?? '';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updatePhone() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    final newPhone = _phoneController.text.trim();
    
    if (newPhone == user.phoneMasked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor baru tidak boleh sama dengan nomor lama')),
      );
      return;
    }

    if (newPhone.isEmpty || newPhone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nomor HP yang valid (min. 10 digit)')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _userService.updatePhoneNumber(user.id, newPhone);
      
      final updatedUser = await _userService.fetchUserProfile(user.id);
      AuthService.currentUser = updatedUser;

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor HP berhasil diperbarui')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui nomor HP: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ganti Nomor HP'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pastikan nomor HP baru Anda aktif untuk menerima informasi layanan.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              const Text(
                'NOMOR HP BARU',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Contoh: 08123456789',
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _updatePhone,
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
