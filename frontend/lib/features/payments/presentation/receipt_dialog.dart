import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/payment_model.dart';

class ReceiptDialog extends StatelessWidget {
  final Payment payment;
  final String patientName;

  const ReceiptDialog({super.key, required this.payment, required this.patientName});

  @override
  Widget build(BuildContext context) {
    final total = payment.totalAmount ?? 0.0;
    final paid = payment.amountPaid ?? 0.0;
    final balance = total - paid;
    
    // Parse the ISO date
    final dateObj = DateTime.tryParse(payment.date);
    final formattedDate = dateObj != null 
        ? "${dateObj.year}-${dateObj.month.toString().padLeft(2, '0')}-${dateObj.day.toString().padLeft(2, '0')} ${dateObj.hour}:${dateObj.minute.toString().padLeft(2, '0')}"
        : payment.date;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Center(
              child: Column(
                children: [
                  Icon(Icons.spa, size: 48, color: Colors.blueGrey),
                  SizedBox(height: 8),
                  Text("CERAGEM SOMALIA", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  Text("Technical Massage Center", style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 4),
                  Text("Mogadishu, Somalia", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(thickness: 2),
            const SizedBox(height: 16),
            
            // Receipt Details
            Center(child: Text("OFFICIAL RECEIPT", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.grey[800]))),
            const SizedBox(height: 16),
            
            _buildRow("Receipt No:", "#INV-${payment.id.toString().padLeft(6, '0')}"),
            _buildRow("Date:", formattedDate),
            _buildRow("Patient Name:", patientName),
            _buildRow("Payment Method:", payment.paymentMethod),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Financials
            _buildRow("Total Bill:", "\$${total.toStringAsFixed(2)}", isBold: true),
            _buildRow("Amount Paid:", "\$${paid.toStringAsFixed(2)}"),
            
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[100],
              child: _buildRow(
                "Remaining Balance:", 
                "\$${balance.toStringAsFixed(2)}", 
                isBold: true, 
                color: balance > 0 ? Colors.red : Colors.green
              ),
            ),
            
            const SizedBox(height: 24),
            const Divider(thickness: 2),
            const SizedBox(height: 24),
            
            // Footer
            const Center(
              child: Column(
                children: [
                  Text("Thank you for choosing Ceragem!", style: TextStyle(fontStyle: FontStyle.italic)),
                  SizedBox(height: 8),
                  Text("For any questions, please contact our support desk.", style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.print),
                label: const Text("Print / Close"),
                onPressed: () => context.pop(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(
            value, 
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: color ?? Colors.black87,
            )
          ),
        ],
      ),
    );
  }
}
