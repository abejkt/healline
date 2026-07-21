/// Live status of the patient's currently active queue number.
class ActiveQueueStatus {
  final String ticketNumber;
  final String statusLabel;
  final String poliName;
  final String doctorName;
  final String calledNumberLabel;
  final int remainingCount;
  final String etaLabel;
  final double progressPercent; // 0.0 - 1.0

  const ActiveQueueStatus({
    required this.ticketNumber,
    required this.statusLabel,
    required this.poliName,
    required this.doctorName,
    required this.calledNumberLabel,
    required this.remainingCount,
    required this.etaLabel,
    required this.progressPercent,
  });

  int get progressPercentLabel => (progressPercent * 100).round();

  factory ActiveQueueStatus.fromMap(Map<String, dynamic> map) {
    return ActiveQueueStatus(
      ticketNumber: map['ticket_number']?.toString() ?? '',
      statusLabel: map['status_label']?.toString() ?? '',
      poliName: map['poli_name']?.toString() ?? '',
      doctorName: map['doctor_name']?.toString() ?? '',
      calledNumberLabel: map['called_number_label']?.toString() ?? '',
      remainingCount: map['remaining_count'] is int
          ? map['remaining_count']
          : int.tryParse(map['remaining_count']?.toString() ?? '0') ?? 0,
      etaLabel: map['eta_label']?.toString() ?? '',
      progressPercent: map['progress_percent'] is num
          ? (map['progress_percent'] as num).toDouble()
          : double.tryParse(map['progress_percent']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ticket_number': ticketNumber,
      'status_label': statusLabel,
      'poli_name': poliName,
      'doctor_name': doctorName,
      'called_number_label': calledNumberLabel,
      'remaining_count': remainingCount,
      'eta_label': etaLabel,
      'progress_percent': progressPercent,
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

/// A scheduled/upcoming queue entry shown under "Antrian lainnya".
class UpcomingQueue {
  final String ticketNumber;
  final String poliName;
  final String scheduleLabel;
  final UpcomingQueueStatus status;

  const UpcomingQueue({
    required this.ticketNumber,
    required this.poliName,
    required this.scheduleLabel,
    required this.status,
  });

  factory UpcomingQueue.fromMap(Map<String, dynamic> map) {
    return UpcomingQueue(
      ticketNumber: map['ticket_number']?.toString() ?? '',
      poliName: map['poli_name']?.toString() ?? '',
      scheduleLabel: map['schedule_label']?.toString() ?? '',
      status: UpcomingQueueStatusLabel.fromString(
          map['status']?.toString() ?? 'mendatang'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ticket_number': ticketNumber,
      'poli_name': poliName,
      'schedule_label': scheduleLabel,
      'status': status.name,
    };
  }
}
