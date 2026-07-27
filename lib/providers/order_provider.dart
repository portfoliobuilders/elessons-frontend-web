import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../models/api/order.dart';
import '../repositories/payment_repository.dart';
import '../repositories/user_repository.dart';
import 'view_status.dart';

/// Purchase history + checkout kickoff.
class OrderProvider extends ChangeNotifier {
  OrderProvider({
    required PaymentRepository paymentRepository,
    required UserRepository userRepository,
  })  : _payments = paymentRepository,
        _users = userRepository;

  final PaymentRepository _payments;
  final UserRepository _users;

  ViewStatus _status = ViewStatus.idle;
  ViewStatus get status => _status;
  String? _error;
  String? get error => _error;

  List<OrderModel> _orders = const [];
  List<OrderModel> get orders => _orders;

  bool _checkingOut = false;
  bool get isCheckingOut => _checkingOut;

  Future<void> loadOrders() async {
    _status = ViewStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _orders = await _users.orders();
      _status = ViewStatus.success;
    } on ApiException catch (e) {
      _error = e.message;
      _status = ViewStatus.error;
    }
    notifyListeners();
  }

  /// Creates a Stripe Checkout session and returns it, or null on error
  /// (message available via [error]).
  Future<CheckoutSession?> startCheckout({
    String? name,
    String? phone,
    String? addressLine,
    String? city,
    String? state,
    String? pincode,
    String? currency,
  }) async {
    _checkingOut = true;
    _error = null;
    notifyListeners();
    try {
      final session = await _payments.checkout(
        name: name,
        phone: phone,
        addressLine: addressLine,
        city: city,
        state: state,
        pincode: pincode,
        currency: currency,
      );
      return session;
    } on ApiException catch (e) {
      _error = e.message;
      return null;
    } finally {
      _checkingOut = false;
      notifyListeners();
    }
  }
}
