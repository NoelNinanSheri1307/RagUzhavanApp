import '../models/rag_query.dart';
import '../models/rag_response.dart';
import '../models/region.dart';
import '../models/field_sensor_data.dart';
import '../models/low_bandwidth_message.dart';
import '../models/farmer.dart';

abstract class RagRepository {
  Future<RagResponse> askQuestion(RagQuery query);
  Future<RagResponse> fetchPresetScenarioResponse(String scenarioKey, {String language = 'en'});
  Future<List<Region>> fetchSupportedRegions();
  Future<FieldSensorData> fetchFieldSensorData(String regionId);
  Future<LowBandwidthMessage> sendLowBandwidthQuery(RagQuery query);
  Future<List<Farmer>> fetchFarmersList();
}
