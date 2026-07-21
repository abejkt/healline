import 'package:flutter/material.dart';
import 'poli.dart';

class MockDatabase {
  MockDatabase._();

  static const List<String> availableYearFilters = ['2026', '2025'];
  static const int totalVisitCount = 12;

  static final DateTime nextVisitDate = DateTime(2026, 5, 15);
}
