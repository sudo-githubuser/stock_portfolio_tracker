import 'package:flutter/material.dart';

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
  final String source;
  final bool isMTF;
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
    this.isMTF = false,
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
    print('Parsing Dhan JSON: $json');

    final quantity = _parseDouble(json['totalQty'] ?? json['netQty'] ?? json['quantity'] ?? 0);
    final avgPrice = _parseDouble(json['avgCostPrice'] ?? json['avgPrice'] ?? json['buyAvgPrice'] ?? 0);
    final currentPrice = avgPrice;

    final symbol = json['tradingSymbol']?.toString() ??
        json['symbol']?.toString() ??
        json['instrumentName']?.toString() ??
        'UNKNOWN';

    final companyName = json['companyName']?.toString() ??
        json['name']?.toString() ??
        json['fullName']?.toString() ??
        symbol;

    final collateralQty = _parseDouble(json['collateralQty'] ?? 0);
    final isMTF = collateralQty > 0;

    print('Detected MTF for $symbol: $isMTF (collateralQty: $collateralQty)');

    return HoldingModel(
      symbol: symbol.toUpperCase(),
      name: companyName,
      quantity: quantity,
      avgPrice: avgPrice,
      currentPrice: currentPrice,
      source: 'dhan',
      isMTF: isMTF,
    );
  }

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
      isMTF: json['isMTF'] == 1 || json['isMTF'] == true,
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
      'isMTF': isMTF,
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
      'isMTF': isMTF ? 1 : 0,
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
    bool? isMTF,
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
      isMTF: isMTF ?? this.isMTF,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  HoldingModel updatePrice(double newPrice) {
    return HoldingModel(
      id: id,
      symbol: symbol,
      name: name,
      quantity: quantity,
      avgPrice: avgPrice,
      currentPrice: newPrice,
      source: source,
      isMTF: isMTF,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  bool get isProfitable => pnl > 0;
  double get absPnL => pnl.abs();
  String get formattedPnLPercent => '${pnl >= 0 ? '+' : ''}${pnlPercent.toStringAsFixed(2)}%';
  String get formattedPnL => '₹${pnl >= 0 ? '+' : ''}${pnl.toStringAsFixed(2)}';
  Color get pnlColor => pnl >= 0 ? Colors.green : Colors.red;

  int get holdingDays => DateTime.now().difference(createdAt).inDays;

  String get formattedHoldingPeriod {
    final days = holdingDays;
    if (days == 0) return 'Today';
    if (days == 1) return '1 day';
    if (days < 30) return '$days days';
    if (days < 365) {
      final months = (days / 30).floor();
      return months == 1 ? '1 month' : '$months months';
    } else {
      final years = (days / 365).floor();
      final remainingMonths = ((days % 365) / 30).floor();
      if (remainingMonths == 0) {
        return years == 1 ? '1 year' : '$years years';
      } else {
        return years == 1
            ? '1 year ${remainingMonths}m'
            : '$years years ${remainingMonths}m';
      }
    }
  }

  bool get isPriceRecent {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);
    return difference.inHours < 1;
  }

  String get formattedCurrentValue => '₹${currentValue.toStringAsFixed(2)}';
  String get formattedInvestedAmount => '₹${investedAmount.toStringAsFixed(2)}';
  String get formattedCurrentPrice => '₹${currentPrice.toStringAsFixed(2)}';
  String get formattedAvgPrice => '₹${avgPrice.toStringAsFixed(2)}';
  String get formattedQuantity => quantity == quantity.toInt()
      ? quantity.toInt().toString()
      : quantity.toStringAsFixed(2);

  @override
  String toString() {
    return 'HoldingModel(id: $id, symbol: $symbol, name: $name, quantity: $quantity, avgPrice: $avgPrice, currentPrice: $currentPrice, source: $source, isMTF: $isMTF, pnl: $pnl, pnlPercent: $pnlPercent)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HoldingModel &&
        other.id == id &&
        other.symbol == symbol &&
        other.source == source;
  }

  @override
  int get hashCode {
    return id.hashCode ^ symbol.hashCode ^ source.hashCode;
  }
}

extension CurrencyFormatter on double {
  String get formatCurrency {
    if (this >= 100000) {
      return "${(this / 100000).toStringAsFixed(2)} L";
    } else if (this >= 1000) {
      return "${(this / 1000).toStringAsFixed(1)} K";
    } else {
      return this.toStringAsFixed(0);
    }
  }
}

extension HoldingListExtensions on List<HoldingModel> {
  double get totalInvested => fold(0.0, (sum, holding) => sum + holding.investedAmount);
  double get totalCurrentValue => fold(0.0, (sum, holding) => sum + holding.currentValue);
  double get totalPnL => fold(0.0, (sum, holding) => sum + holding.pnl);
  double get totalPnLPercent => totalInvested > 0 ? (totalPnL / totalInvested) * 100 : 0.0;

  List<HoldingModel> holdingsBySource(String source) => where((h) => h.source == source).toList();
  List<HoldingModel> get mtfHoldings => where((h) => h.isMTF).toList();
  List<HoldingModel> get profitableHoldings => where((h) => h.isProfitable).toList();
  List<HoldingModel> get lossMakingHoldings => where((h) => !h.isProfitable).toList();

  List<HoldingModel> get sortedByPnL {
    final list = List<HoldingModel>.from(this);
    list.sort((a, b) => b.pnl.compareTo(a.pnl));
    return list;
  }

  List<HoldingModel> get sortedByPnLPercent {
    final list = List<HoldingModel>.from(this);
    list.sort((a, b) => b.pnlPercent.compareTo(a.pnlPercent));
    return list;
  }
}
