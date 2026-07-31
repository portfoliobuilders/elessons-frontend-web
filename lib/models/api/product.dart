import '../../core/config/app_config.dart';
import '../../core/utils/json.dart';
import '../../core/utils/money.dart';

/// A purchasable product (3-tier: FULL_CLASS / SUBJECT / MODULE) with prices.
class Product {
  const Product({
    required this.id,
    required this.type,
    required this.format,
    required this.title,
    this.isActive = true,
    this.gradeId,
    this.subjectId,
    this.chapterId,
    this.accessDays = 365,
    this.prices = const [],
  });

  final String id;
  final String type; // FULL_CLASS | SUBJECT | MODULE
  final String format; // RECORDED | LIVE_AND_RECORDED
  final String title;
  final bool isActive;
  final String? gradeId;
  final String? subjectId;
  final String? chapterId;
  final int accessDays;
  final List<ProductPrice> prices;

  bool get isRecorded => format == 'RECORDED';
  bool get isLive => format == 'LIVE_AND_RECORDED';

  /// Resolve the price for a region/currency, falling back to IN/INR
  /// (mirrors pricing.service.ts → resolvePrice).
  ProductPrice? priceFor({
    String region = AppConfig.defaultRegion,
    String currency = AppConfig.defaultCurrency,
  }) {
    for (final p in prices) {
      if (p.region == region && p.currency == currency) return p;
    }
    for (final p in prices) {
      if (p.region == 'IN' && p.currency == 'INR') return p;
    }
    return prices.isNotEmpty ? prices.first : null;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: Json.str(json['id']),
      type: Json.str(json['type'], 'FULL_CLASS'),
      format: Json.str(json['format'], 'RECORDED'),
      title: Json.str(json['title']),
      isActive: Json.boolVal(json['isActive'], true),
      gradeId: Json.strOrNull(json['gradeId']),
      subjectId: Json.strOrNull(json['subjectId']),
      chapterId: Json.strOrNull(json['chapterId']),
      accessDays: Json.intVal(json['accessDays'], 365),
      prices: Json.list(json['prices']).map(ProductPrice.fromJson).toList(),
    );
  }
}

/// One region/currency price for a product (amounts in minor units).
class ProductPrice {
  const ProductPrice({
    required this.region,
    required this.currency,
    required this.amountCents,
    this.compareAtCents,
    this.stripePriceId,
  });

  final String region;
  final String currency;
  final int amountCents;
  final int? compareAtCents;
  final String? stripePriceId;

  String get displayPrice => Money.formatCents(amountCents, currency);
  String? get displayCompareAt => compareAtCents == null
      ? null
      : Money.formatCents(compareAtCents!, currency);

  factory ProductPrice.fromJson(Map<String, dynamic> json) {
    return ProductPrice(
      region: Json.str(json['region'], 'IN'),
      currency: Json.str(json['currency'], 'INR'),
      amountCents: Json.intVal(json['amountCents']),
      compareAtCents: Json.intOrNull(json['compareAtCents']),
      stripePriceId: Json.strOrNull(json['stripePriceId']),
    );
  }
}
