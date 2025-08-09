class HoldingModel {
  final int? id;
  final String symbol;
  final String name;
  final double quantity;
  final double avgPrice;
  final double currentPrice;
  final double investedAmount;
  final double currentValue;
  final double pnl;
  final double pnlPercent;
  final String source; // 'dhan' or 'manual'
  final DateTime createdAt;
  final DateTime updatedAt;

  HoldingModel({
    this.id,
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.avgPrice,
    required this.currentPrice,
    required this.source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) :
        investedAmount = quantity * avgPrice,
        currentValue = quantity * currentPrice,
        pnl = (quantity * currentPrice) - (quantity * avgPrice),
        pnlPercent = avgPrice > 0 ? (((currentPrice - avgPrice) / avgPrice) * 100) : 0,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory HoldingModel.fromDhanJson(Map<String, dynamic> json) {
    print('Parsing Dhan JSON: $json'); // Debug print

    // Based on Dhan API documentation
    final quantity = _parseDouble(json['totalQty'] ?? 0);
    final avgPrice = _parseDouble(json['avgCostPrice'] ?? 0);

    // For current price, we'll use avgPrice initially since Dhan doesn't provide current market price in holdings
    // We'll need to fetch this separately from market data API
    final currentPrice = avgPrice; // Will be updated later with market data

    final symbol = json['tradingSymbol']?.toString() ?? 'UNKNOWN';

    return HoldingModel(
      symbol: symbol.toUpperCase(),
      name: symbol, // Dhan API doesn't provide company name in holdings
      quantity: quantity,
      avgPrice: avgPrice,
      currentPrice: currentPrice,
      source: 'dhan',
    );
  }

  // Helper method to parse double values safely
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  factory HoldingModel.fromJson(Map<String, dynamic> json) {
    return HoldingModel(
      id: json['id'],
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      quantity: _parseDouble(json['quantity']),
      avgPrice: _parseDouble(json['avgPrice']),
      currentPrice: _parseDouble(json['currentPrice']),
      source: json['source'] ?? 'manual',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'quantity': quantity,
      'avgPrice': avgPrice,
      'currentPrice': currentPrice,
      'investedAmount': investedAmount,
      'currentValue': currentValue,
      'pnl': pnl,
      'pnlPercent': pnlPercent,
      'source': source,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'quantity': quantity,
      'avgPrice': avgPrice,
      'currentPrice': currentPrice,
      'source': source,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  HoldingModel copyWith({
    int? id,
    String? symbol,
    String? name,
    double? quantity,
    double? avgPrice,
    double? currentPrice,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HoldingModel(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      avgPrice: avgPrice ?? this.avgPrice,
      currentPrice: currentPrice ?? this.currentPrice,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
