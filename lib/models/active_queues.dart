class ActiveQueue {
  final DateTime date;
  final String doctorName;
  final String poliName;
  final int? quota;
  final String calledNumberLabel;
  final String lastTicketNumber;

  const ActiveQueue({
    required this.date,
    required this.doctorName,
    required this.poliName,
    required this.quota,
    required this.calledNumberLabel,
    required this.lastTicketNumber,
  });

  bool get isAvailable => quota == null || quota! > 0;

  String get quotaLabel =>
      isAvailable ? 'Kuota Tersedia: $quota' : 'Kuota Tidak Tersedia';

  factory ActiveQueue.fromMap(Map<String, dynamic> map) {
    return ActiveQueue(
      date: DateTime.parse(map['date']?.toString() ?? ''),
      doctorName: map['doctor_name']?.toString() ?? '',
      poliName: map['poli_name']?.toString() ?? '',
      quota: map['quota'] is int
          ? map['quota']
          : int.tryParse(map['quota']?.toString() ?? ''),
      calledNumberLabel: map['called_number_label']?.toString() ?? '',
      lastTicketNumber: map['last_ticket_number']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'doctor_name': doctorName,
      'poli_name': poliName,
      'quota': quota,
      'called_number_label': calledNumberLabel,
      'last_ticket_number': lastTicketNumber,
    };
  }
}

enum UpcomingQueueStatus { mendatang, aktif }

extension UpcomingQueueStatusLabel on UpcomingQueueStatus {
  String get label {
    switch (this) {
      case UpcomingQueueStatus.mendatang:
        return 'Mendatang';
      case UpcomingQueueStatus.aktif:
        return 'Aktif';
    }
  }

  static UpcomingQueueStatus fromString(String status) {
    final lowerStatus = status.toLowerCase();
    return UpcomingQueueStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == lowerStatus,
      orElse: () => UpcomingQueueStatus.mendatang,
    );
  }
}

class UpcomingQueue {
  final String ticketNumber;
  final String poliName;
  final String doctorName;
  final String patientName;
  final DateTime scheduleDate;
  final UpcomingQueueStatus status;

  const UpcomingQueue({
    required this.ticketNumber,
    required this.poliName,
    required this.doctorName,
    required this.patientName,
    required this.scheduleDate,
    required this.status,
  });

  factory UpcomingQueue.fromMap(Map<String, dynamic> map) {
    return UpcomingQueue(
      ticketNumber: map['ticket_number']?.toString() ?? '',
      poliName: map['poli_name']?.toString() ?? '',
      doctorName: map['doctor_name']?.toString() ?? '',
      patientName: map['patient_name']?.toString() ?? '',
      scheduleDate: DateTime.parse(map['schedule_date']?.toString() ?? DateTime.now().toIso8601String()),
      status: UpcomingQueueStatusLabel.fromString(map['status']?.toString() ?? 'mendatang'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ticket_number': ticketNumber,
      'poli_name': poliName,
      'doctor_name': doctorName,
      'patient_name': patientName,
      'schedule_date': scheduleDate.toIso8601String().split('T')[0],
      'status': status.name,
    };
  }
}
