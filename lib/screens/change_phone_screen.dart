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
  final _oldPhoneController = TextEditingController();
  final _newPhoneController = TextEditingController();
  final _userService = UserService();
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPhoneController.dispose();
    _newPhoneController.dispose();
    super.dispose();
  }

  Future<void> _updatePhone() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    final oldPhoneInput = _oldPhoneController.text.trim();
    final newPhoneInput = _newPhoneController.text.trim();
    
    if (oldPhoneInput != user.phoneMasked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor HP lama yang Anda masukkan salah')),
      );
      return;
    }

    if (newPhoneInput == user.phoneMasked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor baru tidak boleh sama dengan nomor lama')),
      );
      return;
    }

    if (newPhoneInput.isEmpty || newPhoneInput.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nomor HP baru yang valid (min. 10 digit)')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _userService.updatePhoneNumber(user.id, newPhoneInput);
      
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Konfirmasikan nomor HP lama Anda sebelum melakukan perubahan.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),

              const _FieldLabel('NOMOR HP LAMA'),
              const SizedBox(height: 8),
              TextField(
                controller: _oldPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Masukkan nomor HP lama Anda',
                ),
              ),
              const SizedBox(height: 24),

              const _FieldLabel('NOMOR HP BARU'),
              const SizedBox(height: 8),
              TextField(
                controller: _newPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Contoh: 08123456789',
                ),
              ),
              const SizedBox(height: 48),

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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}
