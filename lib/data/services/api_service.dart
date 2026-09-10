import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class ApiService {
  late final Dio _dio;
  String _baseUrl;

  ApiService({String baseUrl = ''}) : _baseUrl = baseUrl {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  String get baseUrl => _baseUrl;
  bool get hasBaseUrl => _baseUrl.isNotEmpty;

  void updateBaseUrl(String newUrl) {
    _baseUrl = newUrl;
    _dio.options.baseUrl = newUrl;
  }

  /// POST /auth/login
  Future<Map<String, dynamic>?> login({
    required String username,
    required String password,
    required String role,
  }) async {
    if (!hasBaseUrl) return null;
    try {
      final response = await _dio.post('/auth/login', data: {
        'username': username,
        'password': password,
        'role': role,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST /auth/register
  Future<Map<String, dynamic>?> register(Map<String, dynamic> farmerData) async {
    if (!hasBaseUrl) return null;
    try {
      final response = await _dio.post('/auth/register', data: farmerData);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// GET /regions
  Future<Map<String, dynamic>?> getRegions() async {
    if (!hasBaseUrl) return null;
    try {
      final response = await _dio.get('/regions');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST /rag/query
  Future<Map<String, dynamic>?> queryRag(Map<String, dynamic> queryPayload) async {
    if (!hasBaseUrl) return null;
    try {
      final response = await _dio.post('/rag/query', data: queryPayload);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// GET /rag/evidence?id={evidenceId}
  Future<Map<String, dynamic>?> getEvidence(String evidenceId) async {
    if (!hasBaseUrl) return null;
    try {
      final response = await _dio.get('/rag/evidence', queryParameters: {'id': evidenceId});
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// GET /messages
  Future<List<dynamic>?> getMessages() async {
    if (!hasBaseUrl) return null;
    try {
      final response = await _dio.get('/messages');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// GET /farmers
  Future<List<dynamic>?> getFarmers({
    String? district,
    String? crop,
    String? status,
  }) async {
    if (!hasBaseUrl) return null;
    try {
      final queryParams = <String, dynamic>{};
      if (district != null && district.isNotEmpty) queryParams['district'] = district;
      if (crop != null && crop.isNotEmpty) queryParams['crop'] = crop;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final response = await _dio.get('/farmers', queryParameters: queryParams);
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  ApiException _handleDioError(DioException error) {
    String msg = 'Network error occurred';
    if (error.type == DioExceptionType.connectionTimeout) {
      msg = 'Connection timeout while connecting to server';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      msg = 'Receive timeout while waiting for response';
    } else if (error.response != null) {
      msg = error.response?.data?['message']?.toString() ??
          'Server error with status code ${error.response?.statusCode}';
    }
    return ApiException(msg, statusCode: error.response?.statusCode, data: error.response?.data);
  }
}
