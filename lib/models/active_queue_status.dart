class ActiveQueueStatus {
  final String doctorName;
  final String poliName;
  final String calledNumberLabel;

  const ActiveQueueStatus({
    required this.doctorName,
    required this.poliName,
    required this.calledNumberLabel,
  });

  factory ActiveQueueStatus.fromMap(Map<String, dynamic> map) {
    return ActiveQueueStatus(
      doctorName: map['doctor_name']?.toString() ?? '',
      poliName: map['poli_name']?.toString() ?? '',
      calledNumberLabel: map['called_number_label']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'poli_name': poliName,
      'doctor_name': doctorName,
      'called_number_label': ticketNumber,
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
    return UpcomingQueueStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => UpcomingQueueStatus.mendatang,
    );
  }
}

class UpcomingQueue {
  final String ticketNumber;
  final String poliName;
  final String doctorName;
  final String patientName;
  final String scheduleLabel;
  final UpcomingQueueStatus status;

  const UpcomingQueue({
    required this.ticketNumber,
    required this.poliName,
    required this.doctorName,
    required this.patientName,
    required this.scheduleLabel,
    required this.status,
  });

  factory UpcomingQueue.fromMap(Map<String, dynamic> map) {
    return UpcomingQueue(
      ticketNumber: map['ticket_number']?.toString() ?? '',
      poliName: map['poli_name']?.toString() ?? '',
      doctorName: map['doctor_name']?.toString() ?? '',
      patientName: map['patient_name']?.toString() ?? '',
      scheduleLabel: map['schedule_label']?.toString() ?? '',
      status: UpcomingQueueStatusLabel.fromString(
          map['status']?.toString() ?? 'mendatang'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ticket_number': ticketNumber,
      'poli_name': poliName,
      'doctor_name': doctorName,
      'patient_name': patientName,
      'schedule_label': scheduleLabel,
      'status': status.name,
    };
  }
}
