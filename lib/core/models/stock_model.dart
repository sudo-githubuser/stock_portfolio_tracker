class StockModel {
  final String symbol;
  final String name;
  final double currentPrice;
  final double previousClose;
  final double change;
  final double changePercent;
  final String currency;
  final DateTime lastUpdated;

  StockModel({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.previousClose,
    required this.change,
    required this.changePercent,
    this.currency = 'INR',
    required this.lastUpdated,
  });

  factory StockModel.fromAlphaVantageJson(Map<String, dynamic> json) {
    final globalQuote = json['Global Quote'] ?? {};
    final price = double.tryParse(globalQuote['05. price'] ?? '0') ?? 0.0;
    final previousClose = double.tryParse(globalQuote['08. previous close'] ?? '0') ?? 0.0;
    final change = double.tryParse(globalQuote['09. change'] ?? '0') ?? 0.0;
    final changePercent = double.tryParse(
        globalQuote['10. change percent']?.replaceAll('%', '') ?? '0'
    ) ?? 0.0;

    return StockModel(
      symbol: globalQuote['01. symbol'] ?? '',
      name: globalQuote['01. symbol'] ?? '',
      currentPrice: price,
      previousClose: previousClose,
      change: change,
      changePercent: changePercent,
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'currentPrice': currentPrice,
      'previousClose': previousClose,
      'change': change,
      'changePercent': changePercent,
      'currency': currency,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      currentPrice: json['currentPrice']?.toDouble() ?? 0.0,
      previousClose: json['previousClose']?.toDouble() ?? 0.0,
      change: json['change']?.toDouble() ?? 0.0,
      changePercent: json['changePercent']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'INR',
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }
}
