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
  final _oldEmailController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _userService = UserService();
  bool _isLoading = false;

  @override
  void dispose() {
    _oldEmailController.dispose();
    _newEmailController.dispose();
    super.dispose();
  }

  Future<void> _updateEmail() async {
    final user = AuthService.currentUser;
    if (user == null) return;

    final oldEmailInput = _oldEmailController.text.trim();
    final newEmailInput = _newEmailController.text.trim();
    
    if (oldEmailInput != user.email) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email lama yang Anda masukkan salah')),
      );
      return;
    }

    if (newEmailInput == user.email) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email baru tidak boleh sama dengan email lama')),
      );
      return;
    }

    if (newEmailInput.isEmpty || !newEmailInput.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan alamat email baru yang valid')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _userService.updateEmail(user.id, newEmailInput);
      
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Konfirmasikan email lama Anda sebelum melakukan perubahan.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              
              const _FieldLabel('EMAIL LAMA'),
              const SizedBox(height: 8),
              TextField(
                controller: _oldEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Masukkan email lama Anda',
                ),
              ),
              const SizedBox(height: 24),
              
              const _FieldLabel('EMAIL BARU'),
              const SizedBox(height: 8),
              TextField(
                controller: _newEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'contoh@email.com',
                ),
              ),
              const SizedBox(height: 48),
              
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
