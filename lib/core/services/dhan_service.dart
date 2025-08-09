import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/holding_model.dart';
import 'network_service.dart';

class DhanService {
  static final DhanService _instance = DhanService._internal();
  factory DhanService() => _instance;
  DhanService._internal();

  final NetworkService _networkService = NetworkService();

  Future<Map<String, String>> _getHeaders() async {
    final accessToken = await ApiConfig.getDhanAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Dhan access token not found. Please setup API keys first.');
    }

    // Correct headers based on Dhan API documentation
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'access-token': accessToken,
    };
  }

  Future<bool> validateCredentials(String accessToken) async {
    try {
      final response = await _networkService.get(
        '${ApiConfig.dhanBaseUrl}/holdings',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'access-token': accessToken,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Credential validation error: $e');
      return false;
    }
  }

  Future<List<HoldingModel>> fetchHoldings() async {
    try {
      final headers = await _getHeaders();

      print('Making request to: ${ApiConfig.dhanBaseUrl}/holdings');
      print('Headers: $headers');

      final response = await _networkService.get(
        '${ApiConfig.dhanBaseUrl}/holdings',
        headers: headers,
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        List<Map<String, dynamic>> holdingsList = [];

        // Handle different response formats
        if (data is List) {
          holdingsList = List<Map<String, dynamic>>.from(data);
        } else if (data is Map) {
          if (data.containsKey('data') && data['data'] is List) {
            holdingsList = List<Map<String, dynamic>>.from(data['data']);
          } else if (data.containsKey('holdings') && data['holdings'] is List) {
            holdingsList = List<Map<String, dynamic>>.from(data['holdings']);
          } else {
            throw Exception('Unexpected response format: $data');
          }
        } else {
          throw Exception('Invalid response format');
        }

        // Convert to HoldingModel list
        return holdingsList
            .map((holding) => HoldingModel.fromDhanJson(holding))
            .toList();
      }

      throw Exception('Failed to fetch holdings: ${response.statusCode}');

    } on DioException catch (e) {
      print('DioException: ${e.message}');
      print('Response data: ${e.response?.data}');
      print('Status code: ${e.response?.statusCode}');

      if (e.response?.statusCode == 400) {
        final responseData = e.response?.data;
        String errorMsg = 'Bad request';

        if (responseData is Map) {
          final errorCode = responseData['errorCode'];
          final errorMessage = responseData['errorMessage'];

          if (errorCode == 'DH-906') {
            errorMsg = 'Invalid or expired token. Please regenerate your Dhan API token.';
          } else {
            errorMsg = errorMessage ?? errorMsg;
          }
        }

        throw Exception('Dhan API Error: $errorMsg');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please check your Dhan access token.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access forbidden. Please verify your API permissions.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      print('Unknown error: $e');
      throw Exception('Error fetching holdings: $e');
    }
  }

  // Test connection with better error handling
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final headers = await _getHeaders();

      print('Testing Dhan API connection...');
      print('Headers: $headers');

      final response = await _networkService.get(
        '${ApiConfig.dhanBaseUrl}/holdings',
        headers: headers,
      );

      return {
        'success': true,
        'statusCode': response.statusCode,
        'message': 'Connection successful',
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Connection failed',
      };
    }
  }
}
