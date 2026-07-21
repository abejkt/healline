import 'family_member.dart';

class UserProfile {
  final String id;
  final String name;
  final String initials;
  final String nikMasked;
  final String noRm;
  final bool isVerified;
  final String phoneMasked;
  final String email;
  final List<FamilyMember> familyMembers;

  const UserProfile({
    required this.id,
    required this.name,
    required this.initials,
    required this.nikMasked,
    required this.noRm,
    required this.isVerified,
    required this.phoneMasked,
    required this.email,
    required this.familyMembers,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      initials: map['initials']?.toString() ?? '',
      nikMasked: map['nik_masked']?.toString() ?? '',
      noRm: map['no_rm']?.toString() ?? '',
      isVerified: map['is_verified'] == true,
      phoneMasked: map['phone_masked']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      familyMembers: (map['family_members'] as List<dynamic>?)
              ?.map((e) => FamilyMember.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'initials': initials,
      'nik_masked': nikMasked,
      'no_rm': noRm,
      'is_verified': isVerified,
      'phone_masked': phoneMasked,
      'email': email,
      'family_members': familyMembers.map((e) => e.toMap()).toList(),
    };
  }
}
