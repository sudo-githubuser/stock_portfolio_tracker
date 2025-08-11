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
    return await ApiConfig.getCurrentAlphaVantageKey();
  }

  Future<bool> _isRateLimitResponse(Map<String, dynamic> data) async {
    if (data.containsKey('Note')) {
      final note = data['Note'].toString();
      return note.contains('rate limit') || note.contains('25 requests per day');
    }
    return false;
  }

  Future<StockQuoteModel> fetchStockQuote(String symbol) async {
    int maxRetries = await ApiConfig.getAlphaVantageKeys().then((keys) => keys.length);
    if (maxRetries == 0) {
      throw Exception('No Alpha Vantage API keys configured');
    }

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final apiKey = await _getApiKey();
        if (apiKey == null || apiKey.isEmpty) {
          throw Exception('Alpha Vantage API key not found');
        }

        final symbolWithBSE = symbol.contains('.BSE') ? symbol : '$symbol.BSE';
        print('Fetching quote for symbol: $symbolWithBSE (Attempt ${attempt + 1})');

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

          if (data is Map<String, dynamic>) {
            if (await _isRateLimitResponse(data)) {
              print('Rate limit hit for key: ${apiKey.substring(0, 8)}... Switching to next key.');
              await ApiConfig.switchToNextAlphaVantageKey();
              continue;
            }

            if (data.containsKey('Global Quote')) {
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
          }
        } else {
          throw Exception('Failed to fetch stock quote: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching stock quote for $symbol (attempt ${attempt + 1}): $e');
        if (attempt == maxRetries - 1) {
          throw Exception('Failed to fetch stock quote after $maxRetries attempts: $e');
        }
        await ApiConfig.switchToNextAlphaVantageKey();
      }
    }

    throw Exception('All Alpha Vantage API keys exhausted');
  }

  Future<List<Map<String, dynamic>>> searchSymbols(String keywords) async {
    int maxRetries = await ApiConfig.getAlphaVantageKeys().then((keys) => keys.length);
    if (maxRetries == 0) return [];

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final apiKey = await _getApiKey();
        if (apiKey == null || apiKey.isEmpty) return [];

        print('Searching for: $keywords (Attempt ${attempt + 1})');

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
          if (data is Map<String, dynamic>) {
            if (await _isRateLimitResponse(data)) {
              print('Rate limit hit for search. Switching to next key.');
              await ApiConfig.switchToNextAlphaVantageKey();
              continue;
            }

            if (data.containsKey('bestMatches')) {
              final matches = data['bestMatches'] as List;
              final bseMatches = matches.where((match) {
                final symbol = match['1. symbol']?.toString() ?? '';
                return symbol.contains('.BSE') || symbol.contains('BSE');
              }).toList();

              print('BSE matches found: ${bseMatches.length}');
              return bseMatches.cast<Map<String, dynamic>>();
            }
          }
        }
        return [];
      } catch (e) {
        print('Search error (attempt ${attempt + 1}): $e');
        if (attempt == maxRetries - 1) return [];
        await ApiConfig.switchToNextAlphaVantageKey();
      }
    }
    return [];
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
        if (data is Map<String, dynamic>) {
          if (await _isRateLimitResponse(data)) {
            return true;
          }
          if (data.containsKey('Global Quote')) {
            return true;
          } else if (data.containsKey('Error Message')) {
            return false;
          }
        }
      }
      return false;
    } catch (e) {
      print('API key validation error: $e');
      return false;
    }
  }
}
