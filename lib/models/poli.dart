import 'package:flutter/material.dart';

class Poli {
  final String id;
  final String name;
  final IconData icon;

  const Poli({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory Poli.fromMap(Map<String, dynamic> map) {
    IconData getIcon(String? iconName) {
      switch (iconName) {
        case 'favorite_border': return Icons.favorite_border;
        case 'remove_red_eye_outlined': return Icons.remove_red_eye_outlined;
        case 'child_care_outlined': return Icons.child_care_outlined;
        default: return Icons.add_circle;
      }
    }

    return Poli(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      icon: getIcon(map['icon']?.toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon.toString(),
    };
  }
}
