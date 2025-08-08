import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/stock_model.dart';
import 'network_service.dart';

class AlphaVantageService {
  static final AlphaVantageService _instance = AlphaVantageService._internal();
  factory AlphaVantageService() => _instance;
  AlphaVantageService._internal();

  final NetworkService _networkService = NetworkService();

  Future<String> _getApiKey() async {
    final apiKey = await ApiConfig.getAlphaVantageKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Alpha Vantage API key not found. Please configure it first.');
    }
    return apiKey;
  }

  Future<StockModel> fetchStockQuote(String symbol) async {
    try {
      final apiKey = await _getApiKey();
      final response = await _networkService.get(
        ApiConfig.alphaVantageBaseUrl,
        queryParameters: {
          'function': 'GLOBAL_QUOTE',
          'symbol': symbol,
          'apikey': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('Error Message')) {
            throw Exception('Invalid symbol: $symbol');
          }
          if (data.containsKey('Note')) {
            throw Exception('API limit reached. Please try again later.');
          }
          return StockModel.fromAlphaVantageJson(data);
        }
      }
      throw Exception('Failed to fetch stock quote: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching stock quote: $e');
    }
  }

  Future<List<StockModel>> fetchMultipleQuotes(List<String> symbols) async {
    List<StockModel> stocks = [];

    // Alpha Vantage free tier: 5 requests per minute
    for (int i = 0; i < symbols.length; i++) {
      try {
        final stock = await fetchStockQuote(symbols[i]);
        stocks.add(stock);

        // Rate limiting: wait between requests
        if (i < symbols.length - 1) {
          await Future.delayed(Duration(seconds: 12)); // 5 requests per minute
        }
      } catch (e) {
        print('Failed to fetch quote for ${symbols[i]}: $e');
        // Continue with next symbol
      }
    }

    return stocks;
  }

  Future<Map<String, dynamic>> fetchTimeSeriesDaily(String symbol, {String outputSize = 'compact'}) async {
    try {
      final apiKey = await _getApiKey();
      final response = await _networkService.get(
        ApiConfig.alphaVantageBaseUrl,
        queryParameters: {
          'function': 'TIME_SERIES_DAILY',
          'symbol': symbol,
          'outputsize': outputSize,
          'apikey': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('Error Message')) {
            throw Exception('Invalid symbol: $symbol');
          }
          if (data.containsKey('Note')) {
            throw Exception('API limit reached. Please try again later.');
          }
          return data;
        }
      }
      throw Exception('Failed to fetch time series data: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching time series data: $e');
    }
  }

  Future<Map<String, dynamic>> fetchCompanyOverview(String symbol) async {
    try {
      final apiKey = await _getApiKey();
      final response = await _networkService.get(
        ApiConfig.alphaVantageBaseUrl,
        queryParameters: {
          'function': 'OVERVIEW',
          'symbol': symbol,
          'apikey': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('Error Message')) {
            throw Exception('Invalid symbol: $symbol');
          }
          return data;
        }
      }
      throw Exception('Failed to fetch company overview: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching company overview: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchIntradayData(String symbol, {String interval = '5min'}) async {
    try {
      final apiKey = await _getApiKey();
      final response = await _networkService.get(
        ApiConfig.alphaVantageBaseUrl,
        queryParameters: {
          'function': 'TIME_SERIES_INTRADAY',
          'symbol': symbol,
          'interval': interval,
          'apikey': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final timeSeries = data['Time Series (${interval})'] as Map<String, dynamic>?;
          if (timeSeries != null) {
            return timeSeries.entries.map((entry) => {
              'time': entry.key,
              'open': double.parse(entry.value['1. open']),
              'high': double.parse(entry.value['2. high']),
              'low': double.parse(entry.value['3. low']),
              'close': double.parse(entry.value['4. close']),
              'volume': int.parse(entry.value['5. volume']),
            }).toList();
          }
        }
      }
      throw Exception('Failed to fetch intraday data: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching intraday data: $e');
    }
  }
}
