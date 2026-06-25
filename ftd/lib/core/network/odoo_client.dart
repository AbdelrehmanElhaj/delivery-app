import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../shared/utils/constants.dart';
import '../storage/secure_storage.dart';

final odooClientProvider = Provider<OdooClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return OdooClient(storage);
});

class OdooClient {
  final SecureStorageService _storage;
  late final Dio _dio;
  late final PersistCookieJar _cookieJar;
  bool _initialized = false;

  OdooClient(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.odooBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: false,
      requestBody: true,
      responseBody: true,
      compact: true,
    ));
  }

  // Call once before making requests — sets up persistent cookie jar
  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    final dir = await getApplicationDocumentsDirectory();
    _cookieJar = PersistCookieJar(storage: FileStorage('${dir.path}/.cookies/'));
    _dio.interceptors.insert(0, CookieManager(_cookieJar));
    _initialized = true;
  }

  // Load a known session_id into the cookie jar (used on app restore)
  Future<void> loadSessionCookie(String sessionId) async {
    await _ensureInitialized();
    final uri = Uri.parse(AppConstants.odooBaseUrl);
    await _cookieJar.saveFromResponse(uri, [
      Cookie('session_id', sessionId)..path = '/',
    ]);
  }

  // ─── Authentication ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> authenticate(
      String login, String password) async {
    await _ensureInitialized();
    final res = await _dio.post('/web/session/authenticate', data: {
      'jsonrpc': '2.0',
      'method': 'call',
      'id': 1,
      'params': {
        'db': AppConstants.odooDb,
        'login': login,
        'password': password,
      },
    });

    final result = res.data['result'];
    if (result == null || result['uid'] == null) {
      throw Exception(res.data['error']?['data']?['message'] ??
          'Authentication failed');
    }

    // session_id may be absent from the JSON body for portal users — read from cookie jar
    final sid = result['session_id'];
    if (sid == null || (sid as String).isEmpty) {
      final uri = Uri.parse(AppConstants.odooBaseUrl);
      final cookies = await _cookieJar.loadForRequest(uri);
      final cookieSid = cookies
          .where((c) => c.name == 'session_id')
          .map((c) => c.value)
          .firstOrNull ?? '';
      return Map<String, dynamic>.from(result)..['session_id'] = cookieSid;
    }

    return result;
  }

  Future<void> logout() async {
    await _ensureInitialized();
    try {
      await _dio.post('/web/session/destroy', data: {
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {},
      });
      await _cookieJar.deleteAll();
    } catch (_) {}
  }

  // ─── Generic RPC call ─────────────────────────────────────────────────────

  Future<dynamic> call({
    required String model,
    required String method,
    List<dynamic> args = const [],
    Map<String, dynamic> kwargs = const {},
  }) async {
    await _ensureInitialized();
    final res = await _dio.post('/web/dataset/call_kw', data: {
      'jsonrpc': '2.0',
      'method': 'call',
      'params': {
        'model': model,
        'method': method,
        'args': args,
        'kwargs': kwargs,
      },
    });

    if (res.data['error'] != null) {
      throw Exception(res.data['error']['data']['message']);
    }
    return res.data['result'];
  }

  // ─── Search & Read helper ─────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> searchRead({
    required String model,
    List<dynamic> domain = const [],
    required List<String> fields,
    int? limit,
    int? offset,
    String? order,
  }) async {
    final result = await call(
      model: model,
      method: 'search_read',
      kwargs: {
        'domain': domain,
        'fields': fields,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
        if (order != null) 'order': order,
      },
    );
    return List<Map<String, dynamic>>.from(result);
  }
}
