class SessionNote {
  final int id;
  final int treatmentPlanId;
  final int doctorId;
  final String date;
  final String patientResponse;
  final int painLevel;
  final String notes;
  final String? nextRecommendation;

  SessionNote({
    required this.id,
    required this.treatmentPlanId,
    required this.doctorId,
    required this.date,
    required this.patientResponse,
    required this.painLevel,
    required this.notes,
    this.nextRecommendation,
  });

  factory SessionNote.fromJson(Map<String, dynamic> json) {
    return SessionNote(
      id: json['id'],
      treatmentPlanId: json['treatment_plan_id'],
      doctorId: json['doctor_id'],
      date: json['date'],
      patientResponse: json['patient_response'],
      painLevel: json['pain_level'],
      notes: json['notes'],
      nextRecommendation: json['next_recommendation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'treatment_plan_id': treatmentPlanId,
      'doctor_id': doctorId,
      'date': date,
      'patient_response': patientResponse,
      'pain_level': painLevel,
      'notes': notes,
      'next_recommendation': nextRecommendation,
    };
  }
}
