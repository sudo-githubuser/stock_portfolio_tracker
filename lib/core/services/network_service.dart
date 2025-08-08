import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  late Dio _dio;
  final Connectivity _connectivity = Connectivity();

  void initialize() {
    _dio = Dio();

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('REQUEST: ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('ERROR: ${error.message}');
          handler.next(error);
        },
      ),
    );

    // Set default timeout
    _dio.options.connectTimeout = Duration(seconds: 15);
    _dio.options.receiveTimeout = Duration(seconds: 15);
  }

  Future<bool> isConnected() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<Response> get(
      String url, {
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? headers,
      }) async {
    if (!await isConnected()) {
      throw DioException(
        requestOptions: RequestOptions(path: url),
        message: 'No internet connection',
        type: DioExceptionType.connectionError,
      );
    }

    return await _dio.get(
      url,
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );
  }

  Future<Response> post(
      String url, {
        dynamic data,
        Map<String, dynamic>? headers,
      }) async {
    if (!await isConnected()) {
      throw DioException(
        requestOptions: RequestOptions(path: url),
        message: 'No internet connection',
        type: DioExceptionType.connectionError,
      );
    }

    return await _dio.post(
      url,
      data: data,
      options: Options(headers: headers),
    );
  }

  Stream<ConnectivityResult> get connectivityStream => _connectivity.onConnectivityChanged;
}
