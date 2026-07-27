import '../../core/utils/json.dart';
import '../../core/utils/money.dart';

/// Full cart price breakdown — the shape returned by GET /cart, /cart/quote,
/// add/remove item (pricing.service.ts → Quote).
class CartQuote {
  const CartQuote({
    required this.region,
    required this.currency,
    required this.lines,
    required this.subtotalCents,
    required this.discountCents,
    required this.taxCents,
    required this.totalCents,
  });

  final String region;
  final String currency;
  final List<QuoteLine> lines;
  final int subtotalCents;
  final int discountCents;
  final int taxCents;
  final int totalCents;

  bool get isEmpty => lines.isEmpty;
  int get count => lines.length;

  String money(int cents) => Money.formatCents(cents, currency);
  String get subtotalLabel => money(subtotalCents);
  String get discountLabel => money(discountCents);
  String get taxLabel => money(taxCents);
  String get totalLabel => money(totalCents);

  static const CartQuote empty = CartQuote(
    region: 'IN',
    currency: 'INR',
    lines: [],
    subtotalCents: 0,
    discountCents: 0,
    taxCents: 0,
    totalCents: 0,
  );

  factory CartQuote.fromJson(Map<String, dynamic> json) {
    return CartQuote(
      region: Json.str(json['region'], 'IN'),
      currency: Json.str(json['currency'], 'INR'),
      lines: Json.list(json['lines']).map(QuoteLine.fromJson).toList(),
      subtotalCents: Json.intVal(json['subtotalCents']),
      discountCents: Json.intVal(json['discountCents']),
      taxCents: Json.intVal(json['taxCents']),
      totalCents: Json.intVal(json['totalCents']),
    );
  }
}

class QuoteLine {
  const QuoteLine({
    required this.productId,
    required this.title,
    required this.priceCents,
  });

  final String productId;
  final String title;
  final int priceCents;

  String priceLabel(String currency) => Money.formatCents(priceCents, currency);

  factory QuoteLine.fromJson(Map<String, dynamic> json) {
    return QuoteLine(
      productId: Json.str(json['productId']),
      title: Json.str(json['title']),
      priceCents: Json.intVal(json['priceCents']),
    );
  }
}
