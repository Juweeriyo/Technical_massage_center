class Diagnosis {
  final int id;
  final int patientId;
  final int doctorId;
  final String symptoms;
  final String recommendations;
  final String createdAt;

  Diagnosis({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.symptoms,
    required this.recommendations,
    required this.createdAt,
  });

  factory Diagnosis.fromJson(Map<String, dynamic> json) {
    return Diagnosis(
      id: json['id'],
      patientId: json['patient_id'],
      doctorId: json['doctor_id'],
      symptoms: json['symptoms'],
      recommendations: json['recommendations'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'doctor_id': doctorId,
      'symptoms': symptoms,
      'recommendations': recommendations,
    };
  }
}
