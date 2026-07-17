class TreatmentPlan {
  final int id;
  final int patientId;
  final String treatmentName;
  final int mode;
  final int numberOfSessions;
  final String startDate;
  final String? endDate;
  final String status;

  TreatmentPlan({
    required this.id,
    required this.patientId,
    required this.treatmentName,
    required this.mode,
    required this.numberOfSessions,
    required this.startDate,
    this.endDate,
    required this.status,
  });

  factory TreatmentPlan.fromJson(Map<String, dynamic> json) {
    return TreatmentPlan(
      id: json['id'],
      patientId: json['patient_id'],
      treatmentName: json['treatment_name'],
      mode: json['mode'],
      numberOfSessions: json['number_of_sessions'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'treatment_name': treatmentName,
      'number_of_sessions': numberOfSessions,
      'mode': mode,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
    };
  }
}
