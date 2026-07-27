import '../../core/utils/json.dart';
import '../../core/utils/money.dart';

/// A past order — GET /me/orders (users.service.ts → orders()).
class OrderModel {
  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.currency,
    required this.subtotalCents,
    required this.discountCents,
    required this.taxCents,
    required this.totalCents,
    required this.status,
    this.items = const [],
    this.createdAt,
  });

  final String id;
  final String orderNumber;
  final String currency;
  final int subtotalCents;
  final int discountCents;
  final int taxCents;
  final int totalCents;
  final String status; // PENDING | PAID | FAILED | REFUNDED
  final List<OrderItemModel> items;
  final DateTime? createdAt;

  bool get isPaid => status == 'PAID';
  String money(int cents) => Money.formatCents(cents, currency);
  String get totalLabel => money(totalCents);

  int get itemCount => items.length;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: Json.str(json['id']),
      orderNumber: Json.str(json['orderNumber']),
      currency: Json.str(json['currency'], 'INR'),
      subtotalCents: Json.intVal(json['subtotalCents']),
      discountCents: Json.intVal(json['discountCents']),
      taxCents: Json.intVal(json['taxCents']),
      totalCents: Json.intVal(json['totalCents']),
      status: Json.str(json['status'], 'PENDING'),
      items: Json.list(json['items']).map(OrderItemModel.fromJson).toList(),
      createdAt: Json.dateOrNull(json['createdAt']),
    );
  }
}

class OrderItemModel {
  const OrderItemModel({
    required this.id,
    required this.productId,
    required this.titleSnapshot,
    required this.priceCents,
  });

  final String id;
  final String productId;
  final String titleSnapshot;
  final int priceCents;

  String priceLabel(String currency) => Money.formatCents(priceCents, currency);

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: Json.str(json['id']),
      productId: Json.str(json['productId']),
      titleSnapshot: Json.str(json['titleSnapshot']),
      priceCents: Json.intVal(json['priceCents']),
    );
  }
}

/// POST /checkout response `{ checkoutUrl, orderNumber }`.
class CheckoutSession {
  const CheckoutSession({required this.checkoutUrl, required this.orderNumber});
  final String checkoutUrl;
  final String orderNumber;

  factory CheckoutSession.fromJson(Map<String, dynamic> json) {
    return CheckoutSession(
      checkoutUrl: Json.str(json['checkoutUrl']),
      orderNumber: Json.str(json['orderNumber']),
    );
  }
}
