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
  String? _authToken;

  ApiService({String baseUrl = 'https://backend-production-e510.up.railway.app'}) : _baseUrl = baseUrl {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 25),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  String get baseUrl => _baseUrl;
  bool get hasBaseUrl => _baseUrl.isNotEmpty;
  String? get authToken => _authToken;

  void updateBaseUrl(String newUrl) {
    _baseUrl = newUrl;
    _dio.options.baseUrl = newUrl;
  }

  void setAuthToken(String? token) {
    _authToken = token;
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  // -------------------------
  // Auth Endpoints
  // -------------------------

  /// POST /token (Form URL Encoded for OAuth2 Password Flow)
  Future<Map<String, dynamic>?> login({
    required String username,
    required String password,
    String role = 'farmer',
  }) async {
    if (!hasBaseUrl) return null;
    try {
      final response = await _dio.post(
        '/token',
        data: {
          'username': username,
          'password': password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('access_token')) {
        setAuthToken(data['access_token'] as String);
      }
      return data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST /register or POST /register_admin
  Future<Map<String, dynamic>?> register({
    required String username,
    required String password,
    String role = 'student',
  }) async {
    if (!hasBaseUrl) return null;
    final endpoint = (role == 'admin') ? '/register_admin' : '/register';
    try {
      final response = await _dio.post(endpoint, data: {
        'username': username,
        'password': password,
        'role': role,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// GET /users/me
  Future<Map<String, dynamic>?> getCurrentUser() async {
    if (!hasBaseUrl) return null;
    try {
      final response = await _dio.get('/users/me');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PATCH /users/me
  Future<Map<String, dynamic>?> updateUserProfile(Map<String, dynamic> profileData) async {
    if (!hasBaseUrl) return null;
    try {
      final response = await _dio.patch('/users/me', data: profileData);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// GET /regions (compatibility)
  Future<Map<String, dynamic>?> getRegions() async {
    if (!hasBaseUrl) return null;
    try {
      final response = await _dio.get('/sources/graph');
      return {'sources': response.data};
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// GET /farmers (compatibility)
  Future<List<dynamic>?> getFarmers({String? district, String? crop, String? status}) async {
    if (!hasBaseUrl) return null;
    try {
      final response = await _dio.get('/sources');
      return response.data as List<dynamic>?;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // -------------------------
  // Chat Sessions & RAG Query
  // -------------------------

  /// GET /sessions
  Future<List<dynamic>?> getSessions() async {
    if (!hasBaseUrl) return null;
    try {
      final response = await _dio.get('/sessions');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST /sessions
  Future<Map<String, dynamic>?> createSession() async {
    if (!hasBaseUrl) return null;
    try {
      final response = await _dio.post('/sessions');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// GET /sessions/{id}/messages
  Future<List<dynamic>?> getSessionMessages(int sessionId) async {
    if (!hasBaseUrl) return null;
    try {
      final response = await _dio.get('/sessions/$sessionId/messages');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// DELETE /sessions/{id}
  Future<Map<String, dynamic>?> deleteSession(int sessionId) async {
    if (!hasBaseUrl) return null;
    try {
      final response = await _dio.delete('/sessions/$sessionId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST /sessions/{id}/ask
  Future<Map<String, dynamic>?> askSession(int sessionId, Map<String, dynamic> queryPayload) async {
    if (!hasBaseUrl) return null;
    try {
      final response = await _dio.post('/sessions/$sessionId/ask', data: queryPayload);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST /ask (legacy fallback)
  Future<Map<String, dynamic>?> queryRag(Map<String, dynamic> queryPayload) async {
    if (!hasBaseUrl) return null;
    try {
      final response = await _dio.post('/ask', data: queryPayload);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // -------------------------
  // Knowledge Graph & Sources
  // -------------------------

  /// GET /sources/graph
  Future<List<dynamic>?> getSourcesGraph() async {
    if (!hasBaseUrl) return null;
    try {
      final response = await _dio.get('/sources/graph');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// GET /sources
  Future<List<dynamic>?> getSources() async {
    if (!hasBaseUrl) return null;
    try {
      final response = await _dio.get('/sources');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// DELETE /sources/{id}
  Future<Map<String, dynamic>?> deleteSource(int sourceId) async {
    if (!hasBaseUrl) return null;
    try {
      final response = await _dio.delete('/sources/$sourceId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// GET /admin/settings
  Future<Map<String, dynamic>?> getAdminSettings() async {
    if (!hasBaseUrl) return null;
    try {
      final response = await _dio.get('/admin/settings');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PATCH /admin/settings
  Future<Map<String, dynamic>?> updateAdminSettings(bool guardrailsEnabled) async {
    if (!hasBaseUrl) return null;
    try {
      final response = await _dio.patch('/admin/settings', data: {'guardrails_enabled': guardrailsEnabled});
      return response.data as Map<String, dynamic>;
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
      msg = error.response?.data?['detail']?.toString() ??
          error.response?.data?['message']?.toString() ??
          'Server error with status code ${error.response?.statusCode}';
    }
    return ApiException(msg, statusCode: error.response?.statusCode, data: error.response?.data);
  }
}
