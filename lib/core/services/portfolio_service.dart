import 'package:dio/dio.dart';
import '../models/holding_model.dart';
import '../database/database_helper.dart';
import '../config/api_config.dart';
import 'network_service.dart';

class PortfolioService {
  static final PortfolioService _instance = PortfolioService._internal();
  factory PortfolioService() => _instance;
  PortfolioService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final NetworkService _networkService = NetworkService();

  Future<List<HoldingModel>> getAllHoldings() async {
    try {
      return await _dbHelper.getAllHoldings();
    } catch (e) {
      throw Exception('Failed to get holdings: $e');
    }
  }

  Future<List<HoldingModel>> getHoldingsBySource(String source) async {
    try {
      return await _dbHelper.getHoldingsBySource(source);
    } catch (e) {
      throw Exception('Failed to get holdings by source: $e');
    }
  }

  Future<void> addManualHolding({
    required String symbol,
    required String name,
    required double quantity,
    required double avgPrice,
  }) async {
    try {
      final existingHolding = await _dbHelper.getHoldingBySymbol(symbol, 'manual');

      if (existingHolding != null) {
        final totalQuantity = existingHolding.quantity + quantity;
        final totalInvested = existingHolding.investedAmount + (quantity * avgPrice);
        final newAvgPrice = totalInvested / totalQuantity;

        final updatedHolding = existingHolding.copyWith(
          quantity: totalQuantity,
          avgPrice: newAvgPrice,
          updatedAt: DateTime.now(),
        );

        await _dbHelper.updateHolding(updatedHolding);
      } else {
        final holding = HoldingModel(
          symbol: symbol.toUpperCase(),
          name: name,
          quantity: quantity,
          avgPrice: avgPrice,
          currentPrice: avgPrice,
          source: 'manual',
          isMTF: false,
        );

        await _dbHelper.insertHolding(holding);
      }
    } catch (e) {
      throw Exception('Failed to add manual holding: $e');
    }
  }

  Future<void> syncDhanHoldings() async {
    try {
      final accessToken = await ApiConfig.getDhanAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Dhan access token not found');
      }

      final dio = Dio();
      final response = await dio.get(
        'https://api.dhan.co/holdings',
        options: Options(
          headers: {
            'access-token': accessToken,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> holdingsData = [];

        if (data is Map<String, dynamic>) {
          if (data.containsKey('data') && data['data'] is List) {
            holdingsData = data['data'] as List<dynamic>;
          } else if (data.containsKey('holdings') && data['holdings'] is List) {
            holdingsData = data['holdings'] as List<dynamic>;
          } else if (data.containsKey('positions') && data['positions'] is List) {
            holdingsData = data['positions'] as List<dynamic>;
          }
        } else if (data is List) {
          holdingsData = data as List<dynamic>;
        }

        if (holdingsData.isEmpty) {
          print('No holdings data found in response: $data');
          return;
        }

        await _dbHelper.deleteAllHoldingsBySource('dhan');

        for (var holdingJson in holdingsData) {
          try {
            if (holdingJson is Map<String, dynamic>) {
              final holding = HoldingModel.fromDhanJson(holdingJson);
              await _dbHelper.insertHolding(holding);
            }
          } catch (e) {
            print('Failed to process holding: $holdingJson, error: $e');
          }
        }
      } else {
        throw Exception('Failed to fetch Dhan holdings: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw Exception('Invalid Dhan access token. Please update your credentials.');
        } else if (e.response?.statusCode == 403) {
          throw Exception('Access forbidden. Please check your Dhan API permissions.');
        } else if (e.response?.statusCode == 404) {
          throw Exception('Dhan API endpoint not found. Please check the API URL.');
        }
      }
      throw Exception('Failed to sync Dhan holdings: $e');
    }
  }

  Future<void> updateHoldingPrice(int holdingId, double newPrice) async {
    try {
      await _dbHelper.updateHoldingPrice(holdingId, newPrice);
    } catch (e) {
      throw Exception('Failed to update holding price: $e');
    }
  }

  Future<void> updateAllPrices() async {
    final holdings = await getAllHoldings();
    for (final holding in holdings) {
      try {
        await Future.delayed(Duration(seconds: 1));
      } catch (e) {
        print('Failed to update price for ${holding.symbol}: $e');
      }
    }
  }

  Future<void> deleteHolding(int holdingId) async {
    try {
      await _dbHelper.deleteHolding(holdingId);
    } catch (e) {
      throw Exception('Failed to delete holding: $e');
    }
  }

  Future<Map<String, dynamic>> getPortfolioSummary() async {
    try {
      final holdings = await getAllHoldings();

      double totalInvested = 0.0;
      double totalCurrent = 0.0;
      double totalPnL = 0.0;

      for (final holding in holdings) {
        totalInvested += holding.investedAmount;
        totalCurrent += holding.currentValue;
        totalPnL += holding.pnl;
      }

      final totalPnLPercent = totalInvested > 0 ? (totalPnL / totalInvested) * 100 : 0.0;

      return {
        'totalInvested': totalInvested,
        'totalCurrent': totalCurrent,
        'totalPnL': totalPnL,
        'totalPnLPercent': totalPnLPercent,
        'totalHoldings': holdings.length,
        'profitableHoldings': holdings.where((h) => h.pnl > 0).length,
        'lossMakingHoldings': holdings.where((h) => h.pnl < 0).length,
      };
    } catch (e) {
      throw Exception('Failed to get portfolio summary: $e');
    }
  }

  Future<List<HoldingModel>> getTopPerformers({int limit = 5}) async {
    try {
      final holdings = await getAllHoldings();
      holdings.sort((a, b) => b.pnlPercent.compareTo(a.pnlPercent));
      return holdings.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get top performers: $e');
    }
  }

  Future<List<HoldingModel>> getWorstPerformers({int limit = 5}) async {
    try {
      final holdings = await getAllHoldings();
      holdings.sort((a, b) => a.pnlPercent.compareTo(b.pnlPercent));
      return holdings.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get worst performers: $e');
    }
  }

  Future<void> refreshHoldingPrice(String symbol) async {
    try {
      final holdings = await getAllHoldings();
      final holding = holdings.firstWhere(
            (h) => h.symbol == symbol,
        orElse: () => throw Exception('Holding not found'),
      );

      await Future.delayed(Duration(seconds: 1));
    } catch (e) {
      throw Exception('Failed to refresh price for $symbol: $e');
    }
  }

  Future<bool> hasHoldings() async {
    try {
      final holdings = await getAllHoldings();
      return holdings.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, double>> getSourceWiseInvestment() async {
    try {
      final holdings = await getAllHoldings();
      Map<String, double> sourceWiseInvestment = {
        'dhan': 0.0,
        'manual': 0.0,
      };

      for (final holding in holdings) {
        sourceWiseInvestment[holding.source] = (sourceWiseInvestment[holding.source] ?? 0.0) + holding.investedAmount;
      }

      return sourceWiseInvestment;
    } catch (e) {
      throw Exception('Failed to get source-wise investment: $e');
    }
  }

  Future<List<HoldingModel>> searchHoldings(String query) async {
    try {
      final holdings = await getAllHoldings();
      return holdings.where((holding) =>
      holding.symbol.toLowerCase().contains(query.toLowerCase()) ||
          holding.name.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      throw Exception('Failed to search holdings: $e');
    }
  }

  Future<void> updateHoldingDetails({
    required int holdingId,
    String? name,
    double? quantity,
    double? avgPrice,
  }) async {
    try {
      final holdings = await getAllHoldings();
      final holdingIndex = holdings.indexWhere((h) => h.id == holdingId);

      if (holdingIndex == -1) {
        throw Exception('Holding not found');
      }

      final holding = holdings[holdingIndex];
      final updatedHolding = holding.copyWith(
        name: name,
        quantity: quantity,
        avgPrice: avgPrice,
        updatedAt: DateTime.now(),
      );

      await _dbHelper.updateHolding(updatedHolding);
    } catch (e) {
      throw Exception('Failed to update holding details: $e');
    }
  }

  Future<void> clearAllData() async {
    try {
      await _dbHelper.deleteAllHoldingsBySource('dhan');
      await _dbHelper.deleteAllHoldingsBySource('manual');
    } catch (e) {
      throw Exception('Failed to clear all data: $e');
    }
  }
}
