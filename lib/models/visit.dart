enum VisitStatus { selesai, batal, tidakHadir }

extension VisitStatusLabel on VisitStatus {
  String get label {
    switch (this) {
      case VisitStatus.selesai:
        return 'Selesai';
      case VisitStatus.batal:
        return 'Dibatalkan';
      case VisitStatus.tidakHadir:
        return 'Tidak hadir';
    }
  }

  static VisitStatus fromString(String status) {
    return VisitStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => VisitStatus.selesai,
    );
  }
}

class Visit {
  final String id;
  final String poli;
  final String doctorName;
  final DateTime date;
  final String queueCode;
  final VisitStatus status;

  const Visit({
    required this.id,
    required this.poli,
    required this.doctorName,
    required this.date,
    required this.queueCode,
    required this.status,
  });

  int get year => date.year;

  factory Visit.fromMap(Map<String, dynamic> map) {
    return Visit(
      id: map['id']?.toString() ?? '',
      poli: map['poli']?.toString() ?? '',
      doctorName: map['doctor_name']?.toString() ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      queueCode: map['queue_code']?.toString() ?? '',
      status: VisitStatusLabel.fromString(map['status']?.toString() ?? 'selesai'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'poli': poli,
      'doctor_name': doctorName,
      'date': date.toIso8601String(),
      'queue_code': queueCode,
      'status': status.name,
    };
  }
}
