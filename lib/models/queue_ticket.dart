class QueueTicket {
  final String ticketNumber;
  final String poliName;
  final String doctorName;
  final String dateLabel;
  final String patientName;

  const QueueTicket({
    required this.ticketNumber,
    required this.poliName,
    required this.doctorName,
    required this.dateLabel,
    required this.patientName,
  });

  factory QueueTicket.fromMap(Map<String, dynamic> map) {
    return QueueTicket(
      ticketNumber: map['ticket_number']?.toString() ?? '',
      poliName: map['poli_name']?.toString() ?? '',
      doctorName: map['doctor_name']?.toString() ?? '',
      dateLabel: map['date_label']?.toString() ?? '',
      patientName: map['patient_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ticket_number': ticketNumber,
      'poli_name': poliName,
      'doctor_name': doctorName,
      'date_label': dateLabel,
      'patient_name': patientName,
    };
  }
}
