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
    final quantity = double.tryParse(json['totalQty']?.toString() ?? '0') ?? 0.0;
    final avgPrice = double.tryParse(json['avgPrice']?.toString() ?? '0') ?? 0.0;
    final ltp = double.tryParse(json['ltp']?.toString() ?? '0') ?? 0.0;

    return HoldingModel(
      symbol: json['tradingSymbol'] ?? '',
      name: json['companyName'] ?? json['tradingSymbol'] ?? '',
      quantity: quantity,
      avgPrice: avgPrice,
      currentPrice: ltp,
      source: 'dhan',
    );
  }

  factory HoldingModel.fromJson(Map<String, dynamic> json) {
    return HoldingModel(
      id: json['id'],
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity']?.toDouble() ?? 0.0,
      avgPrice: json['avgPrice']?.toDouble() ?? 0.0,
      currentPrice: json['currentPrice']?.toDouble() ?? 0.0,
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
