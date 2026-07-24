import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'storage_service.dart';
import 'constants.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: kApiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService.instance.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  static final ApiClient instance = ApiClient._();

  String get baseUrl => kApiBaseUrl;

  Dio get dio => _dio;

  Future<Response> get(String path) async {
    return _dio.get(path);
  }

  Future<Response> post(String path, Map<String, dynamic> body) async {
    return _dio.post(path, data: body);
  }

  Future<Response> delete(String path) async {
    return _dio.delete(path);
  }
}
