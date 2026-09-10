import 'package:dio/dio.dart';
import 'rag_repository.dart';
import 'mock_rag_repository.dart';
import '../services/dio_client.dart';
import '../models/rag_query.dart';
import '../models/rag_response.dart';
import '../models/region.dart';
import '../models/field_sensor_data.dart';
import '../models/low_bandwidth_message.dart';
import '../models/farmer.dart';

class ApiRagRepository implements RagRepository {
  final DioClient dioClient;
  final MockRagRepository fallbackMock = MockRagRepository();

  ApiRagRepository(this.dioClient);

  @override
  Future<RagResponse> askQuestion(RagQuery query) async {
    try {
      final response = await dioClient.dio.post(
        '/api/v1/rag/query',
        data: query.toJson(),
      );
      if (response.statusCode == 200 && response.data != null) {
        return RagResponse.fromJson(response.data as Map<String, dynamic>);
      }
    } on DioException {
      // Graceful fallback to mock repository when remote API is unreachable
    }
    return fallbackMock.askQuestion(query);
  }

  @override
  Future<RagResponse> fetchPresetScenarioResponse(String scenarioKey, {String language = 'en'}) async {
    try {
      final response = await dioClient.dio.get(
        '/api/v1/rag/scenarios/$scenarioKey',
        queryParameters: {'lang': language},
      );
      if (response.statusCode == 200 && response.data != null) {
        return RagResponse.fromJson(response.data as Map<String, dynamic>);
      }
    } on DioException {
      // Fallback
    }
    return fallbackMock.fetchPresetScenarioResponse(scenarioKey, language: language);
  }

  @override
  Future<List<Region>> fetchSupportedRegions() async {
    try {
      final response = await dioClient.dio.get('/api/v1/regions');
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data as List<dynamic>;
        return list.map((e) => Region.fromJson(e as Map<String, dynamic>)).toList();
      }
    } on DioException {
      // Fallback
    }
    return fallbackMock.fetchSupportedRegions();
  }

  @override
  Future<FieldSensorData> fetchFieldSensorData(String regionId) async {
    try {
      final response = await dioClient.dio.get('/api/v1/sensors/$regionId');
      if (response.statusCode == 200 && response.data != null) {
        return FieldSensorData.fromJson(response.data as Map<String, dynamic>);
      }
    } on DioException {
      // Fallback
    }
    return fallbackMock.fetchFieldSensorData(regionId);
  }

  @override
  Future<LowBandwidthMessage> sendLowBandwidthQuery(RagQuery query) async {
    try {
      final response = await dioClient.dio.post(
        '/api/v1/low-bandwidth/sms',
        data: query.toJson(),
      );
      if (response.statusCode == 200 && response.data != null) {
        return LowBandwidthMessage.fromJson(response.data as Map<String, dynamic>);
      }
    } on DioException {
      // Fallback
    }
    return fallbackMock.sendLowBandwidthQuery(query);
  }

  @override
  Future<List<Farmer>> fetchFarmersList() async {
    try {
      final response = await dioClient.dio.get('/api/v1/admin/farmers');
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data as List<dynamic>;
        return list.map((e) => Farmer.fromJson(e as Map<String, dynamic>)).toList();
      }
    } on DioException {
      // Fallback
    }
    return fallbackMock.fetchFarmersList();
  }
}
