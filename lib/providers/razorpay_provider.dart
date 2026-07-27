import 'dart:async';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../services/razorpay_service.dart';

enum PaymentStatus { idle, loading, success, failure, cancelled }

/// Provider to manage Razorpay payment workflow, lifecycle, and UI state across the app.
class RazorpayProvider extends ChangeNotifier {
  RazorpayProvider({RazorpayService? service})
      : _service = service ?? RazorpayService();

  final RazorpayService _service;
  Timer? _timeoutTimer;
  String? _accessToken;

  PaymentStatus _status = PaymentStatus.idle;
  PaymentStatus get status => _status;

  bool get isLoading => _status == PaymentStatus.loading;
  bool get isSuccess => _status == PaymentStatus.success;
  bool get isFailure => _status == PaymentStatus.failure;
  bool get isCancelled => _status == PaymentStatus.cancelled;

  RazorpayOrderDetails? _activeOrder;
  RazorpayOrderDetails? get activeOrder => _activeOrder;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  Map<String, dynamic>? _verificationResult;
  Map<String, dynamic>? get verificationResult => _verificationResult;

  void init() {
    debugPrint('💳 [RazorpayProvider]: Initializing Razorpay provider & handlers...');
    _service.initRazorpay(
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentFailure,
      onExternalWallet: _handleExternalWallet,
    );
  }

  @override
  void dispose() {
    _cancelTimeout();
    _service.dispose();
    super.dispose();
  }

  void _startTimeout({int seconds = 120}) {
    _cancelTimeout();
    debugPrint('⏱️ [RazorpayProvider]: Timeout timer started for $seconds seconds.');
    _timeoutTimer = Timer(Duration(seconds: seconds), () {
      if (_status == PaymentStatus.loading) {
        debugPrint('⏰ [RazorpayProvider]: Payment timed out after $seconds seconds.');
        _status = PaymentStatus.failure;
        _errorMessage = 'Payment request timed out or was closed. Please try again.';
        notifyListeners();
      }
    });
  }

  void _cancelTimeout() {
    if (_timeoutTimer != null) {
      debugPrint('⏱️ [RazorpayProvider]: Cancelling timeout timer.');
      _timeoutTimer?.cancel();
      _timeoutTimer = null;
    }
  }

  void reset() {
    _cancelTimeout();
    _status = PaymentStatus.idle;
    _errorMessage = null;
    _successMessage = null;
    _activeOrder = null;
    _verificationResult = null;
    _accessToken = null;
    notifyListeners();
  }

  /// Initiates full cart checkout (`POST /checkout` -> `openRazorpayCheckout`).
  Future<void> startCartCheckout({
    required String accessToken,
    required Map<String, dynamic> studentInfo,
    String? studentPhone,
    String? studentEmail,
  }) async {
    _accessToken = accessToken;
    _status = PaymentStatus.loading;
    _errorMessage = null;
    _successMessage = null;
    _startTimeout(seconds: 120);
    notifyListeners();

    try {
      final orderDetails = await _service.createCheckout(
        accessToken: accessToken,
        studentInfo: studentInfo,
      );
      _activeOrder = orderDetails;

      _service.openRazorpayCheckout(
        orderDetails,
        studentPhone: studentPhone ?? (studentInfo['phone']?.toString()),
        studentEmail: studentEmail,
      );
    } catch (e) {
      debugPrint('🚨 [RazorpayProvider]: Checkout error: $e');
      _cancelTimeout();
      _status = PaymentStatus.failure;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  /// Initiates direct subject checkout (`POST /razorpay/subject-order` -> `openRazorpayCheckout`).
  Future<void> startSubjectCheckout({
    String? studentId,
    String? studentEmail,
    required String subjectId,
    String? studentPhone,
    String? accessToken,
  }) async {
    _accessToken = accessToken;
    _status = PaymentStatus.loading;
    _errorMessage = null;
    _successMessage = null;
    _startTimeout(seconds: 120);
    notifyListeners();

    try {
      final orderDetails = await _service.createSubjectOrder(
        studentId: studentId,
        studentEmail: studentEmail,
        subjectId: subjectId,
      );
      _activeOrder = orderDetails;

      _service.openRazorpayCheckout(
        orderDetails,
        studentPhone: studentPhone,
        studentEmail: studentEmail,
      );
    } catch (e) {
      debugPrint('🚨 [RazorpayProvider]: Subject checkout error: $e');
      _cancelTimeout();
      _status = PaymentStatus.failure;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  /// Internal handler when Razorpay SDK fires `EVENT_PAYMENT_SUCCESS`.
  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("PAYMENT_SUCCESS_FIRED");
    _cancelTimeout();
    debugPrint('🔔 [RazorpayProvider]: ==========================================');
    debugPrint('🔔 [RazorpayProvider]: EVENT_PAYMENT_SUCCESS callback FIRED!');
    debugPrint('   Payment ID: ${response.paymentId}');
    debugPrint('   Order ID (from SDK): ${response.orderId}');
    debugPrint('   Signature: ${response.signature}');
    debugPrint('   Active Order ID (Saved): ${_activeOrder?.orderId}');
    debugPrint('🔔 [RazorpayProvider]: ==========================================');

    final String finalOrderId = (response.orderId != null && response.orderId!.isNotEmpty)
        ? response.orderId!
        : (_activeOrder?.orderId ?? '');
    final String finalPaymentId = response.paymentId ?? '';
    final String finalSignature = response.signature ?? '';

    _status = PaymentStatus.loading;
    _startTimeout(seconds: 30);
    notifyListeners();

    try {
      if (finalOrderId.isEmpty || finalPaymentId.isEmpty) {
        throw Exception(
          'Incomplete payment details received: Order ID="$finalOrderId", Payment ID="$finalPaymentId".',
        );
      }

      print("BEFORE_VERIFY_CALL");
      debugPrint('🌐 [RazorpayProvider]: Invoking /api/razorpay/verify...');
      final verifyData = await _service.verifyPayment(
        razorpayOrderId: finalOrderId,
        razorpayPaymentId: finalPaymentId,
        razorpaySignature: finalSignature,
        accessToken: _accessToken,
      );

      _cancelTimeout();
      print("AFTER_VERIFY_CALL_SUCCESS");
      debugPrint('✅ [RazorpayProvider]: Verification successful! Payload: $verifyData');
      _verificationResult = verifyData;
      _status = PaymentStatus.success;
      _successMessage = (verifyData['message'] ?? 'Payment verified & course unlocked!').toString();
      notifyListeners();
    } catch (e, st) {
      print("AFTER_VERIFY_CALL_CATCH");
      debugPrint('🚨 [RazorpayProvider]: Payment verification error: $e');
      debugPrint('   StackTrace: $st');
      _cancelTimeout();
      _status = PaymentStatus.failure;
      _errorMessage = 'Payment received, but verification failed: ${e.toString().replaceAll('Exception: ', '')}';
      notifyListeners();
    }
  }

  /// Internal handler when Razorpay SDK fires `EVENT_PAYMENT_ERROR`.
  void _handlePaymentFailure(PaymentFailureResponse response) {
    print("PAYMENT_ERROR_FIRED");
    _cancelTimeout();
    debugPrint('🔔 [RazorpayProvider]: ==========================================');
    debugPrint('❌ [RazorpayProvider]: EVENT_PAYMENT_ERROR callback FIRED!');
    debugPrint('   Code: ${response.code}');
    debugPrint('   Message: ${response.message}');
    debugPrint('🔔 [RazorpayProvider]: ==========================================');

    // Code 2 = PAYMENT_CANCELLED in razorpay_flutter
    if (response.code == Razorpay.PAYMENT_CANCELLED ||
        (response.message != null && response.message!.toLowerCase().contains('cancel'))) {
      _status = PaymentStatus.cancelled;
      _errorMessage = 'Payment was cancelled.';
    } else {
      _status = PaymentStatus.failure;
      _errorMessage = response.message ?? 'Payment failed. Please try again.';
    }
    notifyListeners();
  }

  /// Internal handler for external wallets.
  void _handleExternalWallet(ExternalWalletResponse response) {
    print("EXTERNAL_WALLET_FIRED");
    _cancelTimeout();
    debugPrint('👛 [RazorpayProvider]: External Wallet selected: ${response.walletName}');
  }
}
