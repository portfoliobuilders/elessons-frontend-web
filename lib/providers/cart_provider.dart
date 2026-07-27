import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../models/api/cart_quote.dart';
import '../repositories/cart_repository.dart';
import 'view_status.dart';

/// Server-backed cart. Every mutation returns the fresh price breakdown, so the
/// quote (subtotal/tax/total) is always authoritative.
class CartProvider extends ChangeNotifier {
  CartProvider(this._repo);
  final CartRepository _repo;

  ViewStatus _status = ViewStatus.idle;
  ViewStatus get status => _status;
  String? _error;
  String? get error => _error;

  CartQuote _quote = CartQuote.empty;
  CartQuote get quote => _quote;
  int get count => _quote.count;
  bool get isEmpty => _quote.isEmpty;

  bool _mutating = false;
  bool get isMutating => _mutating;

  Future<void> load({String? currency}) async {
    _status = ViewStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _quote = await _repo.view(currency: currency);
      _status = ViewStatus.success;
    } on ApiException catch (e) {
      _error = e.message;
      _status = ViewStatus.error;
    }
    notifyListeners();
  }

  /// Returns a user-facing message on failure (e.g. "already own this"), else null.
  Future<String?> add(String productId) async {
    _mutating = true;
    notifyListeners();
    try {
      _quote = await _repo.addItem(productId);
      _status = ViewStatus.success;
      return null;
    } on ApiException catch (e) {
      return e.message;
    } finally {
      _mutating = false;
      notifyListeners();
    }
  }

  Future<void> remove(String productId) async {
    _mutating = true;
    notifyListeners();
    try {
      _quote = await _repo.removeItem(productId);
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _mutating = false;
      notifyListeners();
    }
  }

  Future<void> clear() async {
    _mutating = true;
    notifyListeners();
    try {
      _quote = await _repo.clear();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _mutating = false;
      notifyListeners();
    }
  }

  /// Called after a successful checkout — the backend empties the cart on
  /// fulfilment, but we clear locally too for immediate UI feedback.
  void resetLocal() {
    _quote = CartQuote.empty;
    notifyListeners();
  }
}
