class Patient {
  final int id;
  final String patientNumber;
  final String fullName;
  final String phoneNumber;
  final String gender;
  final int age;
  final String address;
  final String? medicalNotes;
  final DateTime registrationDate;

  Patient({
    required this.id,
    required this.patientNumber,
    required this.fullName,
    required this.phoneNumber,
    required this.gender,
    required this.age,
    required this.address,
    this.medicalNotes,
    required this.registrationDate,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      patientNumber: json['patient_number'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      gender: json['gender'],
      age: json['age'],
      address: json['address'],
      medicalNotes: json['medical_notes'],
      registrationDate: DateTime.parse(json['registration_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'gender': gender,
      'age': age,
      'address': address,
      'medical_notes': medicalNotes,
    };
  }
}
