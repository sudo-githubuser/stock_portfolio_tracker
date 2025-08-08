import '../database/database_helper.dart';
import '../models/holding_model.dart';
import '../models/stock_model.dart';
import 'dhan_service.dart';
import 'alpha_vantage_service.dart';

class PortfolioService {
  static final PortfolioService _instance = PortfolioService._internal();
  factory PortfolioService() => _instance;
  PortfolioService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final DhanService _dhanService = DhanService();
  final AlphaVantageService _alphaVantageService = AlphaVantageService();

  // Sync holdings from Dhan
  Future<List<HoldingModel>> syncDhanHoldings() async {
    try {
      final dhanHoldings = await _dhanService.fetchHoldings();

      // Clear existing Dhan holdings
      final existingHoldings = await _dbHelper.getAllHoldings();
      for (final holding in existingHoldings) {
        if (holding.source == 'dhan') {
          await _dbHelper.deleteHolding(holding.id!);
        }
      }

      // Insert new Dhan holdings
      for (final holding in dhanHoldings) {
        await _dbHelper.insertHolding(holding);
      }

      // Update prices for all holdings
      await updateAllPrices();

      return await _dbHelper.getAllHoldings();
    } catch (e) {
      throw Exception('Failed to sync Dhan holdings: $e');
    }
  }

  // Add manual holding
  Future<HoldingModel> addManualHolding({
    required String symbol,
    required String name,
    required double quantity,
    required double avgPrice,
  }) async {
    try {
      // Check if holding already exists
      final existingHolding = await _dbHelper.getHoldingBySymbol(symbol);
      if (existingHolding != null) {
        throw Exception('Stock $symbol already exists in portfolio');
      }

      // Get current price from Alpha Vantage
      double currentPrice = avgPrice; // Default to avg price
      try {
        final stockData = await _alphaVantageService.fetchStockQuote(symbol);
        currentPrice = stockData.currentPrice;
        await _dbHelper.insertOrUpdateStockPrice(stockData);
      } catch (e) {
        print('Could not fetch current price for $symbol: $e');
      }

      final holding = HoldingModel(
        symbol: symbol.toUpperCase(),
        name: name,
        quantity: quantity,
        avgPrice: avgPrice,
        currentPrice: currentPrice,
        source: 'manual',
      );

      final id = await _dbHelper.insertHolding(holding);
      return holding.copyWith(id: id);
    } catch (e) {
      throw Exception('Failed to add manual holding: $e');
    }
  }

  // Update holding
  Future<HoldingModel> updateHolding(HoldingModel holding) async {
    try {
      await _dbHelper.updateHolding(holding);
      return holding;
    } catch (e) {
      throw Exception('Failed to update holding: $e');
    }
  }

  // Delete holding
  Future<void> deleteHolding(int id) async {
    try {
      await _dbHelper.deleteHolding(id);
    } catch (e) {
      throw Exception('Failed to delete holding: $e');
    }
  }

  // Get all holdings
  Future<List<HoldingModel>> getAllHoldings() async {
    try {
      return await _dbHelper.getAllHoldings();
    } catch (e) {
      throw Exception('Failed to get holdings: $e');
    }
  }

  // Update prices for all holdings
  Future<void> updateAllPrices() async {
    try {
      final holdings = await _dbHelper.getAllHoldings();
      final symbols = holdings.map((h) => h.symbol).toSet().toList();

      // Fetch updated prices (rate limited)
      for (final symbol in symbols) {
        try {
          final stockData = await _alphaVantageService.fetchStockQuote(symbol);
          await _dbHelper.insertOrUpdateStockPrice(stockData);

          // Update holdings with new price
          final holdingsToUpdate = holdings.where((h) => h.symbol == symbol);
          for (final holding in holdingsToUpdate) {
            final updatedHolding = holding.copyWith(
              currentPrice: stockData.currentPrice,
              updatedAt: DateTime.now(),
            );
            await _dbHelper.updateHolding(updatedHolding);
          }

          // Rate limiting
          await Future.delayed(Duration(seconds: 12));
        } catch (e) {
          print('Failed to update price for $symbol: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to update prices: $e');
    }
  }

  // Get portfolio summary
  Future<Map<String, dynamic>> getPortfolioSummary() async {
    try {
      final holdings = await _dbHelper.getAllHoldings();

      double totalInvested = 0;
      double totalCurrent = 0;
      double totalPnL = 0;

      for (final holding in holdings) {
        totalInvested += holding.investedAmount;
        totalCurrent += holding.currentValue;
        totalPnL += holding.pnl;
      }

      final totalPnLPercent = totalInvested > 0 ? (totalPnL / totalInvested * 100) : 0;

      return {
        'totalInvested': totalInvested,
        'totalCurrent': totalCurrent,
        'totalPnL': totalPnL,
        'totalPnLPercent': totalPnLPercent,
        'holdingsCount': holdings.length,
        'lastUpdated': DateTime.now(),
      };
    } catch (e) {
      throw Exception('Failed to get portfolio summary: $e');
    }
  }

  // Get stock price from cache or API
  Future<StockModel?> getStockPrice(String symbol) async {
    try {
      // Try cache first
      final cachedStock = await _dbHelper.getStockPriceBySymbol(symbol);
      if (cachedStock != null) {
        // Check if data is recent (within 5 minutes)
        final diff = DateTime.now().difference(cachedStock.lastUpdated);
        if (diff.inMinutes < 5) {
          return cachedStock;
        }
      }

      // Fetch fresh data
      final stockData = await _alphaVantageService.fetchStockQuote(symbol);
      await _dbHelper.insertOrUpdateStockPrice(stockData);
      return stockData;
    } catch (e) {
      // Return cached data if available, even if old
      return await _dbHelper.getStockPriceBySymbol(symbol);
    }
  }

  // Record transaction
  Future<void> recordTransaction({
    required String symbol,
    required String type, // 'buy' or 'sell'
    required double quantity,
    required double price,
    required DateTime date,
  }) async {
    try {
      await _dbHelper.insertTransaction({
        'symbol': symbol,
        'type': type,
        'quantity': quantity,
        'price': price,
        'date': date.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to record transaction: $e');
    }
  }
}
