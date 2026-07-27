/// Formats integer minor units (paise/cents) into a display price.
/// Backend stores `amountCents`; INR display shows whole rupees e.g. ₹11,999.
class Money {
  Money._();

  static const Map<String, String> _symbols = {
    'INR': '₹',
    'AED': 'د.إ ',
    'USD': '\$',
  };

  static String symbol(String currency) => _symbols[currency] ?? '$currency ';

  /// e.g. formatCents(1199900, 'INR') -> "₹11,999".
  static String formatCents(int cents, String currency) {
    final major = cents / 100;
    final whole = major.truncateToDouble() == major
        ? major.toInt().toString()
        : major.toStringAsFixed(2);
    return '${symbol(currency)}${_group(whole)}';
  }

  /// Indian grouping (₹11,99,999) for whole-number strings; falls through for
  /// decimals. Keeps the design's rupee formatting.
  static String _group(String number) {
    final neg = number.startsWith('-');
    var digits = neg ? number.substring(1) : number;
    final dotIndex = digits.indexOf('.');
    String frac = '';
    if (dotIndex != -1) {
      frac = digits.substring(dotIndex);
      digits = digits.substring(0, dotIndex);
    }
    if (digits.length <= 3) return '${neg ? '-' : ''}$digits$frac';
    final last3 = digits.substring(digits.length - 3);
    var rest = digits.substring(0, digits.length - 3);
    final buf = StringBuffer();
    while (rest.length > 2) {
      buf.write(',${rest.substring(rest.length - 2)}');
      rest = rest.substring(0, rest.length - 2);
    }
    final grouped = rest + buf.toString();
    return '${neg ? '-' : ''}$grouped,$last3$frac';
  }
}
