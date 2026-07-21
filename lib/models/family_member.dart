import 'package:flutter/material.dart';

class FamilyMember {
  final String id;
  final String name;
  final String relation;
  final String initials;
  final Color avatarColor;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.initials,
    required this.avatarColor,
  });

  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    Color parseColor(dynamic value) {
      if (value == null) return Colors.grey;
      if (value is int) return Color(value);
      if (value is String) {
        String cleanHex = value.replaceAll('#', '').replaceAll('0x', '');
        if (cleanHex.length == 6) cleanHex = 'FF$cleanHex';
        return Color(int.parse(cleanHex, radix: 16));
      }
      return Colors.grey;
    }

    return FamilyMember(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      relation: map['relation']?.toString() ?? '',
      initials: map['initials']?.toString() ?? '',
      avatarColor: parseColor(map['avatar_color']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'relation': relation,
      'initials': initials,
      'avatar_color': avatarColor.value.toString(),
    };
  }
}
