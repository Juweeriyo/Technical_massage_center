class Payment {
  final int id;
  final int patientId;
  final double amount;
  final String paymentMethod;
  final String status;
  final String date;

  Payment({
    required this.id,
    required this.patientId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.date,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      patientId: json['patient_id'],
      amount: json['amount'].toDouble(),
      paymentMethod: json['payment_method'],
      status: json['status'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'amount': amount,
      'payment_method': paymentMethod,
      'status': status,
    };
  }
}
