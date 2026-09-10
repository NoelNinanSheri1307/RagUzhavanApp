import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';

class DioClient {
  final AppConfig config;
  late final Dio _dio;

  DioClient(this.config) {
    _dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-App': AppConfig.appName,
          'X-Client-Version': AppConfig.appVersion,
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );
  }

  Dio get dio => _dio;
}
