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
    final clientId = await ApiConfig.getDhanClientId();
    final accessToken = await ApiConfig.getDhanAccessToken();

    if (clientId == null || accessToken == null) {
      throw Exception('Dhan credentials not found. Please login first.');
    }

    return {
      'client-id': clientId,
      'access-token': accessToken,
      'Content-Type': 'application/json',
    };
  }

  Future<bool> validateCredentials(String clientId, String accessToken) async {
    try {
      final response = await _networkService.get(
        '${ApiConfig.dhanBaseUrl}/holdings',
        headers: {
          'client-id': clientId,
          'access-token': accessToken,
          'Content-Type': 'application/json',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<HoldingModel>> fetchHoldings() async {
    try {
      final headers = await _getHeaders();
      final response = await _networkService.get(
        '${ApiConfig.dhanBaseUrl}/holdings',
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] is List) {
          final holdingsList = data['data'] as List;
          return holdingsList.map((holding) => HoldingModel.fromDhanJson(holding)).toList();
        }
      }
      throw Exception('Failed to fetch holdings: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchPositions() async {
    try {
      final headers = await _getHeaders();
      final response = await _networkService.get(
        '${ApiConfig.dhanBaseUrl}/positions',
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      throw Exception('Failed to fetch positions: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    try {
      final headers = await _getHeaders();
      final response = await _networkService.get(
        '${ApiConfig.dhanBaseUrl}/orders',
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      throw Exception('Failed to fetch orders: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }
}
