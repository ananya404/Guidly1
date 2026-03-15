import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_functions/cloud_functions.dart';

class PaymentService {
  late Razorpay _razorpay;
  final Function(PaymentSuccessResponse) onSuccess;
  final Function(PaymentFailureResponse) onFailure;
  final Function(ExternalWalletResponse) onExternalWallet;

  PaymentService({
    required this.onSuccess,
    required this.onFailure,
    required this.onExternalWallet,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  Future<void> checkout(double amount, String receiptId) async {
    try {
      // Step 1: Create an order on our backend using Cloud Functions
      final result = await FirebaseFunctions.instance
          .httpsCallable('createRazorpayOrder')
          .call({
        'amount': amount,
        'currency': 'INR',
        'receipt': receiptId,
      });

      final String orderId = result.data['id'];

      // Step 2: Open Razorpay checkout passing the order ID
      var options = {
        'key': 'YOUR_RAZORPAY_KEY', // Update with your actual publishable key
        'amount': (amount * 100).toInt(),
        'name': 'Guidly Travel',
        'description': 'Trip Payment',
        'order_id': orderId,
        'timeout': 120,
        'prefill': {
          'contact': '9876543210',
          'email': 'test@example.com'
        }
      };

      _razorpay.open(options);
    } catch (e) {
      print('Error starting payment: $e');
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
