import 'package:flutter/material.dart';
import 'poli.dart';

class MockDatabase {
  MockDatabase._();

  static const List<String> availableYearFilters = ['2026', '2025'];
  static const int totalVisitCount = 12;

  static const List<Poli> polis = [
    Poli(id: 'umum', name: 'Poli Umum', icon: Icons.add_circle),
    Poli(id: 'jantung', name: 'Poli Jantung', icon: Icons.favorite_border),
    Poli(id: 'mata', name: 'Poli Mata', icon: Icons.remove_red_eye_outlined),
    Poli(id: 'anak', name: 'Poli Anak', icon: Icons.child_care_outlined),
  ];

  static final DateTime nextVisitDate = DateTime(2026, 5, 15);
}
