import 'package:get/get.dart';

class PaymentService extends GetxService {
  Future<Map<String, dynamic>> processPayment(double amount, String currency) async {
    // Simulate payment process
    await Future.delayed(const Duration(seconds: 2));
    
    return {
      'success': true,
      'transactionId': 'pay_${DateTime.now().millisecondsSinceEpoch}',
      'method': 'Credit Card',
      'amount': amount,
      'currency': currency,
    };
  }
}
