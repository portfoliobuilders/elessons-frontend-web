import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/api/order.dart';

/// Checkout (payments.controller.ts → POST /checkout). Creates a Stripe
/// Checkout session from the cart and returns its hosted URL.
class PaymentRepository {
  PaymentRepository(this._api);
  final ApiClient _api;

  Future<CheckoutSession> checkout({
    String? name,
    String? phone,
    String? addressLine,
    String? city,
    String? state,
    String? pincode,
    String? currency,
  }) async {
    final body = {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (addressLine != null) 'addressLine': addressLine,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (pincode != null) 'pincode': pincode,
      if (currency != null) 'currency': currency,
    };
    final res = await _api.post(
      ApiEndpoints.checkout,
      body: body.isEmpty ? null : body,
    );
    return CheckoutSession.fromJson(res as Map<String, dynamic>);
  }
}
