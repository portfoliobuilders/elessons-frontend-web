import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/api/cart_quote.dart';

/// Cart operations (cart.controller.ts). Every mutation returns the refreshed
/// [CartQuote] price breakdown.
class CartRepository {
  CartRepository(this._api);
  final ApiClient _api;

  Future<CartQuote> view({String? currency}) async {
    final uri = currency != null
        ? '${ApiEndpoints.cartQuote}?currency=$currency'
        : ApiEndpoints.cartQuote;
    final res = await _api.get(uri);
    return CartQuote.fromJson(res as Map<String, dynamic>);
  }

  Future<CartQuote> addItem(String productId) async {
    final res =
        await _api.post(ApiEndpoints.cartItems, body: {'productId': productId});
    return CartQuote.fromJson(res as Map<String, dynamic>);
  }

  Future<CartQuote> removeItem(String productId) async {
    final res = await _api.delete(ApiEndpoints.cartItem(productId));
    return CartQuote.fromJson(res as Map<String, dynamic>);
  }

  Future<CartQuote> clear() async {
    final res = await _api.delete(ApiEndpoints.cart);
    return CartQuote.fromJson(res as Map<String, dynamic>);
  }
}
