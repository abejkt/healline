import 'dart:math';
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/family_member_service.dart';

class AddFamilyMemberScreen extends StatefulWidget {
  static const routeName = '/add-family-member';

  const AddFamilyMemberScreen({super.key});

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedRelation = 'Istri';
  bool _isLoading = false;

  final _familyMemberService = FamilyMemberService();
  final _userService = UserService();

  final List<String> _relations = ['Istri', 'Suami', 'Anak', 'Orang Tua', 'Saudara'];
  final List<Color> _avatarColors = [
    const Color(0xFFF3C98B),
    const Color(0xFFA9DDBF),
    const Color(0xFFDCEAFB),
    const Color(0xFFF7DEDC),
    const Color(0xFFE7E5E0),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = AuthService.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join('').toUpperCase();
      final randomColor = _avatarColors[Random().nextInt(_avatarColors.length)];

      final memberData = {
        'id': 'fam-${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'relation': _selectedRelation,
        'initials': initials,
        'avatar_color': randomColor.value.toString(),
      };

      await _familyMemberService.addFamilyMember(user.id, memberData);

      final updatedUser = await _userService.fetchUserProfile(user.id);
      AuthService.currentUser = updatedUser;

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anggota keluarga berhasil ditambahkan')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan anggota keluarga: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Keluarga'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tambahkan anggota keluarga untuk memudahkan pendaftaran antrian bagi mereka.',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),

                const _FieldLabel('NAMA LENGKAP'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan nama anggota keluarga',
                  ),
                  validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 24),

                const _FieldLabel('HUBUNGAN KELUARGA'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedRelation,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  items: _relations.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (v) => setState(() => _selectedRelation = v!),
                ),
                const SizedBox(height: 48),

                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Tambah Anggota Keluarga'),
                ),
              ],
            ),
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
