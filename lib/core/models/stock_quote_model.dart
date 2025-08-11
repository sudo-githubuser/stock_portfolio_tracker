class StockQuoteModel {
  final String symbol;
  final double currentPrice;
  final double change;
  final double changePercent;
  final double volume;
  final String lastTradingDay;

  StockQuoteModel({
    required this.symbol,
    required this.currentPrice,
    required this.change,
    required this.changePercent,
    required this.volume,
    required this.lastTradingDay,
  });

  factory StockQuoteModel.fromJson(Map<String, dynamic> json) {
    return StockQuoteModel(
      symbol: json['symbol'] ?? '',
      currentPrice: (json['currentPrice'] ?? 0.0).toDouble(),
      change: (json['change'] ?? 0.0).toDouble(),
      changePercent: (json['changePercent'] ?? 0.0).toDouble(),
      volume: (json['volume'] ?? 0.0).toDouble(),
      lastTradingDay: json['lastTradingDay'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'currentPrice': currentPrice,
      'change': change,
      'changePercent': changePercent,
      'volume': volume,
      'lastTradingDay': lastTradingDay,
    };
  }

  @override
  String toString() {
    return 'StockQuoteModel(symbol: $symbol, currentPrice: $currentPrice, change: $change, changePercent: $changePercent)';
  }
}
