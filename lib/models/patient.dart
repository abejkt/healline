class Patient {
  final String id;
  final String name;
  final String relationLabel;

  const Patient({
    required this.id,
    required this.name,
    required this.relationLabel,
  });

  String get displayName => '$name ($relationLabel)';

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      relationLabel: map['relation_label']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'relation_label': relationLabel,
    };
  }
}
