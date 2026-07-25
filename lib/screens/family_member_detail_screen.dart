import 'package:flutter/material.dart';
import '../models/family_member.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/family_member_service.dart';
import '../themes/app_theme.dart';

class FamilyMemberDetailScreen extends StatefulWidget {
  static const routeName = '/family-member-detail';

  const FamilyMemberDetailScreen({super.key});

  @override
  State<FamilyMemberDetailScreen> createState() => _FamilyMemberDetailScreenState();
}

class _FamilyMemberDetailScreenState extends State<FamilyMemberDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _selectedRelation;
  bool _isLoading = false;
  bool _isInitialized = false;
  late FamilyMember _member;

  final _familyMemberService = FamilyMemberService();
  final _userService = UserService();

  final List<String> _relations = ['Istri', 'Suami', 'Anak', 'Orang Tua', 'Saudara'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _member = ModalRoute.of(context)!.settings.arguments as FamilyMember;
      _nameController = TextEditingController(text: _member.name);
      _selectedRelation = _member.relation;
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateMember() async {
    if (!_formKey.currentState!.validate()) return;

    final user = AuthService.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join('').toUpperCase();

      final memberData = {
        'name': name,
        'relation': _selectedRelation,
        'initials': initials,
      };

      await _familyMemberService.updateFamilyMember(_member.id, memberData);

      final updatedUser = await _userService.fetchUserProfile(user.id);
      AuthService.currentUser = updatedUser;

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data keluarga berhasil diperbarui')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui data keluarga: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMember() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Anggota Keluarga?'),
        content: Text('Apakah Anda yakin ingin menghapus ${_member.name} dari daftar keluarga?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final user = AuthService.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await _familyMemberService.deleteFamilyMember(_member.id);

      final updatedUser = await _userService.fetchUserProfile(user.id);
      AuthService.currentUser = updatedUser;

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anggota keluarga berhasil dihapus')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus anggota keluarga: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Keluarga'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _isLoading ? null : _deleteMember,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: _member.avatarColor,
                    child: Text(
                      _member.initials,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
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
                  onPressed: _isLoading ? null : _updateMember,
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan Perubahan'),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _isLoading ? null : _deleteMember,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Hapus Anggota Keluarga'),
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
