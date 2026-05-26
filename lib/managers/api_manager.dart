import 'package:open_source_software/api/api_client.dart';
import 'package:dio/dio.dart';

class ApiManager {
  static final ApiManager _instance = ApiManager._internal();
  factory ApiManager() => _instance;
  ApiManager._internal();

  Dio get dio => ApiClient.dio;
}