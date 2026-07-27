import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../core/config/app_config.dart';
import '../core/constants/api_endpoints.dart';

/// Response payload from backend `POST /checkout` or `POST /razorpay/subject-order`.
class RazorpayOrderDetails {
  RazorpayOrderDetails({
    required this.key,
    required this.orderId,
    required this.internalOrderId,
    required this.orderNumber,
    required this.amount,
    required this.currency,
    required this.name,
    required this.description,
    this.rawJson = const {},
  });

  final String key;
  final String orderId;
  final String internalOrderId;
  final String orderNumber;
  final int amount; // Amount in paise
  final String currency;
  final String name;
  final String description;
  final Map<String, dynamic> rawJson;

  factory RazorpayOrderDetails.fromJson(Map<String, dynamic> json) {
    final String keyVal = (json['key'] ?? json['keyId'] ?? '').toString();
    final String orderIdVal = (json['orderId'] ?? json['razorpayOrderId'] ?? '').toString();
    final String internalId = (json['internalOrderId'] ?? json['id'] ?? '').toString();
    final String orderNum = (json['orderNumber'] ?? '').toString();
    final int amountVal = json['amount'] is num
        ? (json['amount'] as num).toInt()
        : int.tryParse(json['amount']?.toString() ?? '0') ?? 0;
    final String currencyVal = (json['currency'] ?? 'INR').toString();
    final String nameVal = (json['name'] ?? 'G-TEC e-Lessons').toString();
    final String descVal = (json['description'] ?? 'Order Payment').toString();

    return RazorpayOrderDetails(
      key: keyVal,
      orderId: orderIdVal,
      internalOrderId: internalId,
      orderNumber: orderNum,
      amount: amountVal,
      currency: currencyVal,
      name: nameVal,
      description: descVal,
      rawJson: json,
    );
  }
}

/// Service handling API communication for Razorpay payments and native SDK integration.
class RazorpayService {
  RazorpayService({http.Client? httpClient})
      : _client = httpClient ?? http.Client();

  final http.Client _client;
  Razorpay? _razorpay;

  /// Initializes the Razorpay SDK instance and registers event listeners.
  void initRazorpay({
    required void Function(PaymentSuccessResponse) onSuccess,
    required void Function(PaymentFailureResponse) onFailure,
    required void Function(ExternalWalletResponse) onExternalWallet,
  }) {
    _disposeRazorpay();
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
    debugPrint('💳 [RazorpayService]: Razorpay SDK initialized & event listeners registered (Success/Error/Wallet).');
  }

  /// Disposes of the active Razorpay SDK instance.
  void _disposeRazorpay() {
    if (_razorpay != null) {
      try {
        _razorpay!.clear();
      } catch (e) {
        debugPrint('⚠️ [RazorpayService]: Error clearing Razorpay instance: $e');
      }
      _razorpay = null;
    }
  }

  void dispose() {
    _disposeRazorpay();
  }

  /// POST /checkout
  /// Creates a Razorpay order for cart items requiring Bearer <accessToken>.
  Future<RazorpayOrderDetails> createCheckout({
    required String accessToken,
    required Map<String, dynamic> studentInfo,
  }) async {
    final String url = '${AppConfig.baseUrl}${ApiEndpoints.checkout}';
    debugPrint('🌐 [RazorpayService]: POST $url');
    debugPrint('   Payload: ${jsonEncode(studentInfo)}');

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    try {
      final http.Response res = await _client
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(studentInfo),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('📩 [RazorpayService]: Response Code: ${res.statusCode}');
      debugPrint('📩 [RazorpayService]: Response Body: ${res.body}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(jsonDecode(res.body) as Map);
        return RazorpayOrderDetails.fromJson(data);
      } else {
        String errorMsg = 'Failed to create checkout order (${res.statusCode})';
        try {
          final Map<String, dynamic> errJson = Map<String, dynamic>.from(jsonDecode(res.body) as Map);
          if (errJson.containsKey('message')) {
            errorMsg = errJson['message'].toString();
          }
        } catch (_) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('🚨 [RazorpayService]: HTTP Error in createCheckout: $e');
      throw Exception('Server error: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  /// POST /razorpay/subject-order
  /// Public endpoint to create direct payment order for a single subject.
  Future<RazorpayOrderDetails> createSubjectOrder({
    String? studentId,
    String? studentEmail,
    required String subjectId,
  }) async {
    final String url = '${AppConfig.baseUrl}${ApiEndpoints.razorpaySubjectOrder}';
    debugPrint('🌐 [RazorpayService]: POST $url');

    final Map<String, dynamic> body = {
      if (studentId != null && studentId.isNotEmpty) 'studentId': studentId,
      if (studentEmail != null && studentEmail.isNotEmpty) 'studentEmail': studentEmail,
      'subjectId': subjectId,
    };

    try {
      final http.Response res = await _client
          .post(
            Uri.parse(url),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('📩 [RazorpayService]: Response Code: ${res.statusCode}');
      debugPrint('📩 [RazorpayService]: Response Body: ${res.body}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(jsonDecode(res.body) as Map);
        return RazorpayOrderDetails.fromJson(data);
      } else {
        String errorMsg = 'Failed to create subject order (${res.statusCode})';
        try {
          final Map<String, dynamic> errJson = Map<String, dynamic>.from(jsonDecode(res.body) as Map);
          if (errJson.containsKey('message')) {
            errorMsg = errJson['message'].toString();
          }
        } catch (_) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('🚨 [RazorpayService]: HTTP Error in createSubjectOrder: $e');
      throw Exception('Server error: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  /// POST /razorpay/verify
  /// Public/Authenticated endpoint called after Razorpay payment success to verify signature and unlock enrollment.
  Future<Map<String, dynamic>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    String? accessToken,
  }) async {
    final String url = '${AppConfig.baseUrl}${ApiEndpoints.razorpayVerify}';
    debugPrint('🌐 [RazorpayService]: POST $url (Verifying payment)');

    final Map<String, dynamic> body = {
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
    };

    debugPrint('   Request Body: ${jsonEncode(body)}');

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };

    try {
      final http.Response res = await _client
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      debugPrint('📩 [RazorpayService]: Verification Response Code: ${res.statusCode}');
      debugPrint('📩 [RazorpayService]: Verification Response Body: ${res.body}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(jsonDecode(res.body) as Map);
        return data;
      } else {
        String errorMsg = 'Payment verification failed (${res.statusCode})';
        try {
          final Map<String, dynamic> errJson = Map<String, dynamic>.from(jsonDecode(res.body) as Map);
          if (errJson.containsKey('message')) {
            errorMsg = errJson['message'].toString();
          }
        } catch (_) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('🚨 [RazorpayService]: Verification Exception: $e');
      rethrow;
    }
  }

  /// Launches the Razorpay Checkout Sheet using options prepared from order details.
  void openRazorpayCheckout(
    RazorpayOrderDetails checkoutData, {
    String? studentPhone,
    String? studentEmail,
  }) {
    if (_razorpay == null) {
      debugPrint('🚨 [RazorpayService]: _razorpay instance is null during openRazorpayCheckout!');
      throw Exception('Razorpay SDK is not initialized.');
    }

    final Map<String, dynamic> options = {
      'key': checkoutData.key,
      'amount': checkoutData.amount,
      'currency': checkoutData.currency,
      'name': checkoutData.name,
      'description': checkoutData.description,
      'order_id': checkoutData.orderId,
      'prefill': {
        'contact': studentPhone ?? '',
        'email': studentEmail ?? '',
      },
      'theme': {
        'color': '#2563EB',
      },
    };

    debugPrint('🚀 [RazorpayService]: Opening Razorpay Sheet');
    debugPrint('   Key: ${checkoutData.key}');
    debugPrint('   Order ID: ${checkoutData.orderId}');
    debugPrint('   Amount: ${checkoutData.amount} ${checkoutData.currency}');

    try {
      _razorpay!.open(options);
      debugPrint('✨ [RazorpayService]: _razorpay.open() invoked successfully.');
    } catch (e, st) {
      debugPrint('🚨 [RazorpayService]: Exception opening Razorpay SDK: $e');
      debugPrint('   StackTrace: $st');
      throw Exception('Could not open Razorpay checkout: $e');
    }
  }
}
