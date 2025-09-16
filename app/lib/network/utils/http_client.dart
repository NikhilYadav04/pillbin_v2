import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../config/api_config.dart';

class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal();

  late Dio _dio;
  String? _authToken;

  //* Secure storage - automatically encrypted
  static const _secureStorage = FlutterSecureStorage();

  //* Storage keys
  static final String _authTokenKey = dotenv.get("AUTH_TOKEN_KEY");
  static final String _refreshTokenKey = dotenv.get("REFRESH_TOKEN_KEY");
  static final String _userDataKey = dotenv.get("USER_DATA_KEY");
  static final String _isAuthenticatedKey = dotenv.get("IS_AUTHENTICATED_KEY");

  Dio get dio => _dio;

  Future<void> init() async {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
      sendTimeout: Duration(milliseconds: ApiConfig.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    //* Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          //* Add auth token if available
          final token = await getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            print('REQUEST: ${options.method} ${options.uri}');
            print('HEADERS: ${options.headers}');
            print('DATA: ${options.data}');
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print(
                'RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
            print('DATA: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            print(
                'ERROR: ${error.response?.statusCode} ${error.requestOptions.uri}');
            print('MESSAGE: ${error.message}');
          }

          //* Handle 401 Unauthorized
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              //* Retry request with new token
              final options = error.requestOptions;
              final token = await getAuthToken();
              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
              }

              try {
                final response = await _dio.fetch(options);
                handler.resolve(response);
                return;
              } catch (e) {
                //* If retry fails, continue with original error
              }
            } else {
              //* Clear auth data on refresh failure
              await logout();
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  //* ============ TOKEN METHODS ============

  //* Method 2: Store token in SecureStorage (persistent)
  Future<void> saveAuthToken(String token) async {
    _authToken = token;
    await _secureStorage.write(key: _authTokenKey, value: token);
    await _secureStorage.write(key: _isAuthenticatedKey, value: 'true');
  }

  Future<String?> getAuthToken() async {
    //* First check memory for fast access
    if (_authToken != null) return _authToken;

    //* If not in memory, check secure storage
    _authToken = await _secureStorage.read(key: _authTokenKey);
    return _authToken;
  }

  Future<void> removeAuthToken() async {
    _authToken = null;
    await _secureStorage.delete(key: _authTokenKey);
    await _secureStorage.write(key: _isAuthenticatedKey, value: 'false');
  }

  //* Method 3: Store refresh token for automatic token refresh
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    _authToken = accessToken;
    await _secureStorage.write(key: _authTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    await _secureStorage.write(key: _isAuthenticatedKey, value: 'true');
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      //* Make refresh token request
      // final response = await _dio.post(
      //   '/auth/refresh',
      //   data: {'refresh_token': refreshToken},
      //   options: Options(
      //     headers: {
      //       'Authorization': 'Bearer $refreshToken',
      //     },
      //   ),
      // );

      // if (response.statusCode == 200) {
      //   final newAccessToken = response.data['access_token'];
      //   final newRefreshToken = response.data['refresh_token'];

      //   await saveTokens(newAccessToken, newRefreshToken);
      //   return true;
      // }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Token refresh failed: $e');
      }
      //* Remove invalid tokens
      await removeAuthToken();
      await _secureStorage.delete(key: _refreshTokenKey);
    }
    return false;
  }

  //* Method 4: Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    final tokenRefresh = await getRefreshToken();

    Logger().d("Token is Valid ${token!}");
    Logger().d("Token is Valid ${tokenRefresh}");

    if (token.isEmpty) {
      return false;
    } else {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/user/test',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 401) {
        //* Retry with refresh token
        final retryResponse = await _dio.get(
          '${ApiConfig.baseUrl}/api/user/test',
          options: Options(
            headers: {
              'Authorization': 'Bearer $tokenRefresh',
            },
          ),
        );

        if (retryResponse.statusCode == 200) {
          return true;
        } else {
          logout();
          return false;
        }
      } else {
        return true;
      }
    }
  }

  //* Method 5: Logout - clear all tokens
  Future<void> logout() async {
    await removeAuthToken();
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _userDataKey);
    await _secureStorage.write(key: _isAuthenticatedKey, value: 'false');
  }
}
