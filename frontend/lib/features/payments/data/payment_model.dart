class Payment {
  final int id;
  final int patientId;
  final double? totalAmount;
  final double? amountPaid;
  final String paymentMethod;
  final String status;
  final String date;

  Payment({
    required this.id,
    required this.patientId,
    this.totalAmount,
    this.amountPaid,
    required this.paymentMethod,
    required this.status,
    required this.date,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      patientId: json['patient_id'],
      totalAmount: json['total_amount'] != null ? json['total_amount'].toDouble() : null,
      amountPaid: json['amount_paid'] != null ? json['amount_paid'].toDouble() : null,
      paymentMethod: json['payment_method'],
      status: json['status'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'total_amount': totalAmount,
      'amount_paid': amountPaid,
      'payment_method': paymentMethod,
      'status': status,
    };
  }
}
