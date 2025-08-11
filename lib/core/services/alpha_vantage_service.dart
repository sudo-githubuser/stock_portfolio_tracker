import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/stock_quote_model.dart';
import 'network_service.dart';

class AlphaVantageService {
  static final AlphaVantageService _instance = AlphaVantageService._internal();
  factory AlphaVantageService() => _instance;
  AlphaVantageService._internal();

  final NetworkService _networkService = NetworkService();

  Future<String?> _getApiKey() async {
    return await ApiConfig.getAlphaVantageApiKey();
  }

  Future<StockQuoteModel> fetchStockQuote(String symbol) async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('Alpha Vantage API key not found');
      }

      final symbolWithBSE = symbol.contains('.BSE') ? symbol : '$symbol.BSE';
      print('Fetching quote for symbol: $symbolWithBSE');

      final response = await _networkService.get(
        ApiConfig.alphaVantageBaseUrl,
        queryParameters: {
          'function': 'GLOBAL_QUOTE',
          'symbol': symbolWithBSE,
          'apikey': apiKey,
        },
      );

      print('Alpha Vantage quote response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('Global Quote')) {
          final globalQuote = data['Global Quote'] as Map<String, dynamic>;

          final priceString = globalQuote['05. price']?.toString() ?? '0.0';
          final price = double.tryParse(priceString) ?? 0.0;

          final changeString = globalQuote['09. change']?.toString() ?? '0.0';
          final change = double.tryParse(changeString) ?? 0.0;

          final changePercentString = globalQuote['10. change percent']?.toString() ?? '0.00%';
          final changePercent = double.tryParse(changePercentString.replaceAll('%', '')) ?? 0.0;

          print('Parsed price: $price for $symbolWithBSE');

          return StockQuoteModel(
            symbol: globalQuote['01. symbol']?.toString() ?? symbol,
            currentPrice: price,
            change: change,
            changePercent: changePercent,
            volume: double.tryParse(globalQuote['06. volume']?.toString() ?? '0') ?? 0,
            lastTradingDay: globalQuote['07. latest trading day']?.toString() ?? '',
          );
        } else {
          print('Invalid response format: $data');
          throw Exception('Invalid response format from Alpha Vantage');
        }
      } else {
        throw Exception('Failed to fetch stock quote: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching stock quote for $symbol: $e');
      throw Exception('Failed to fetch stock quote: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchSymbols(String keywords) async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('Alpha Vantage API key not found');
      }

      print('Searching for: $keywords');

      final response = await _networkService.get(
        ApiConfig.alphaVantageBaseUrl,
        queryParameters: {
          'function': 'SYMBOL_SEARCH',
          'keywords': keywords,
          'apikey': apiKey,
        },
      );

      print('Alpha Vantage search response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('bestMatches')) {
          final matches = data['bestMatches'] as List;
          final bseMatches = matches.where((match) {
            final symbol = match['1. symbol']?.toString() ?? '';
            return symbol.contains('.BSE') || symbol.contains('BSE');
          }).toList();

          print('BSE matches found: ${bseMatches.length}');
          return bseMatches.cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (e) {
      print('Search error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getMarketStatus() async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('Alpha Vantage API key not found');
      }

      final response = await _networkService.get(
        ApiConfig.alphaVantageBaseUrl,
        queryParameters: {
          'function': 'MARKET_STATUS',
          'apikey': apiKey,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch market status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch market status: $e');
    }
  }

  Future<bool> validateApiKey() async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        return false;
      }

      final response = await _networkService.get(
        ApiConfig.alphaVantageBaseUrl,
        queryParameters: {
          'function': 'GLOBAL_QUOTE',
          'symbol': 'RELIANCE.BSE',
          'apikey': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('Global Quote')) {
          return true;
        } else if (data is Map<String, dynamic> && data.containsKey('Error Message')) {
          return false;
        } else if (data is Map<String, dynamic> && data.containsKey('Note')) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('API key validation error: $e');
      return false;
    }
  }
}
