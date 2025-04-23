import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DioClient {
  late Dio dio;
  late PersistCookieJar cookieJar;

  // Private constructor
  DioClient._();

  // Factory constructor that ensures async initialization
  static Future<DioClient> create() async {
    final instance = DioClient._();
    await instance._initDio();
    return instance;
  }

  Future<void> _initDio() async {
    final dir = await getApplicationDocumentsDirectory();
    cookieJar = PersistCookieJar(
      storage: FileStorage('${dir.path}/.cookies/'),
    );

    dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(CookieManager(cookieJar));
  }

  Future<Response> login({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    final response = await dio.post(
      '$baseUrl/api/method/login',
      data: {
        'usr': username,
        'pwd': password,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    return response;
  }

  Future<Response> get(String url) async {
    return dio.get(url);
  }

  Future<Response> post(String url, Map<String, dynamic> data) async {
    return dio.post(url, data: data);
  }
}
