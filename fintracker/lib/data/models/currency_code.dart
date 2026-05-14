enum CurrencyCode { pln, eur, usd }

extension CurrencyCodeExtension on CurrencyCode {
  String get code {
    switch (this) {
      case CurrencyCode.pln:
        return 'PLN';
      case CurrencyCode.eur:
        return 'EUR';
      case CurrencyCode.usd:
        return 'USD';
    }
  }

  static CurrencyCode fromCode(String? code) {
    switch (code?.toUpperCase()) {
      case 'EUR':
        return CurrencyCode.eur;
      case 'USD':
        return CurrencyCode.usd;
      case 'PLN':
      default:
        return CurrencyCode.pln;
    }
  }
}