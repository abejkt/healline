enum VisitStatus { selesai, batal, tidakHadir, terjadwal }

extension VisitStatusLabel on VisitStatus {
  String get label {
    switch (this) {
      case VisitStatus.selesai:
        return 'Selesai';
      case VisitStatus.batal:
        return 'Dibatalkan';
      case VisitStatus.tidakHadir:
        return 'Tidak hadir';
      case VisitStatus.terjadwal:
        return 'Terjadwal';
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
  final String poli;
  final String doctorName;
  final DateTime date;
  final String ticketNumber;
  final VisitStatus status;

  const Visit({
    required this.poli,
    required this.doctorName,
    required this.date,
    required this.ticketNumber,
    required this.status,
  });

  int get year => date.year;

  factory Visit.fromMap(Map<String, dynamic> map) {
    return Visit(
      poli: map['poli']?.toString() ?? '',
      doctorName: map['doctor_name']?.toString() ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      ticketNumber: map['ticket_number']?.toString() ?? '',
      status: VisitStatusLabel.fromString(map['status']?.toString() ?? 'selesai'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'poli': poli,
      'doctor_name': doctorName,
      'date': date.toIso8601String(),
      'ticket_number': ticketNumber,
      'status': status.name,
    };
  }
}
