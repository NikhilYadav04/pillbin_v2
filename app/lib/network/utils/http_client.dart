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
  bool _isOnline = true;

  //* Secure storage - automatically encrypted
  static const _secureStorage = FlutterSecureStorage();

  //* Storage keys
  static final String _authTokenKey = dotenv.get("AUTH_TOKEN_KEY");
  static final String _refreshTokenKey = dotenv.get("REFRESH_TOKEN_KEY");
  static final String _userDataKey = dotenv.get("USER_DATA_KEY");
  static final String _isAuthenticatedKey = dotenv.get("IS_AUTHENTICATED_KEY");

  static final String _nameKey = dotenv.get('USER_NAME_KEY');
  static final String _phoneKey = dotenv.get('USER_PHONE_KEY');
  static final String _emailKey = dotenv.get('USER_EMAIL_KEY');

  Dio get dio => _dio;
  bool get isOnline => _isOnline;

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
          _isOnline = true;
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

          //* Check if its a connection error ( offline )
          if (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.unknown) {
            _isOnline = false;
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

      //* Make refresh token requestp
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
    try {
      final token = await getAuthToken();
      final tokenRefresh = await getRefreshToken();

      Logger().d("Access Token: ${token != null ? 'Valid' : 'Invalid'}");
      Logger()
          .d("Refresh Token: ${tokenRefresh != null ? 'Valid' : 'Invalid'}");

      if (token == null || token.isEmpty) {
        return false;
      }

      //* If we have a token, check if we can reach the server
      try {
        final response = await _dio.get(
          '${ApiConfig.baseUrl}/api/user/test',
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
            sendTimeout: Duration(seconds: 5),
            receiveTimeout: Duration(seconds: 5),
          ),
        );

        if (response.statusCode == 200) {
          _isOnline = true;
          return true;
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          //* Try with refresh token
          if (tokenRefresh != null) {
            final retryResponse = await _dio.get(
              '${ApiConfig.baseUrl}/api/user/test',
              options: Options(
                headers: {
                  'Authorization': 'Bearer $tokenRefresh',
                },
                sendTimeout: Duration(seconds: 5),
                receiveTimeout: Duration(seconds: 5),
              ),
            );

            if (retryResponse.statusCode == 200) {
              _isOnline = true;
              return true;
            }
          }

          //* Token is invalid
          await logout();
          return false;
        }
      } on DioException catch (e) {
        //* If connection error, assume offline but token exists
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.unknown) {
          _isOnline = false;
          Logger()
              .w("Connection error - assuming offline mode with valid token");
          //* We have a token, but can't verify it online
          //* Allow user to proceed with cached data
          return true;
        }

        //* Other errors (like 401) mean token is invalid
        await logout();
        return false;
      }

      return false;
    } catch (e) {
      Logger().e("Authentication check error: $e");
      //* If we have a token but can't verify, assume offline
      final token = await getAuthToken();
      if (token != null && token.isNotEmpty) {
        _isOnline = false;
        return true;
      }
      return false;
    }
  }

  //* Check network connectivity
  Future<bool> checkConnection() async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/health',
        options: Options(
          sendTimeout: Duration(seconds: 3),
          receiveTimeout: Duration(seconds: 3),
        ),
      );
      _isOnline = response.statusCode == 200;
      return _isOnline;
    } catch (e) {
      _isOnline = false;
      return false;
    }
  }

  //* Method 5: Logout - clear all tokens
  Future<void> logout() async {
    await removeAuthToken();
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _userDataKey);
    await removeUserData();
    await _secureStorage.write(key: _isAuthenticatedKey, value: 'false');
  }

  //* ============ USER DATA METHODS ============

  //* save data
  Future<void> saveUserData(String name, String phone, String email) async {
    await _secureStorage.write(key: _nameKey, value: name);
    await _secureStorage.write(key: _emailKey, value: email);
    await _secureStorage.write(key: _phoneKey, value: phone);
  }

  //* remove data
  Future<void> removeUserData() async {
    await _secureStorage.delete(key: _nameKey);
    await _secureStorage.delete(key: _emailKey);
    await _secureStorage.delete(key: _phoneKey);
  }

  //* Get data
  Future<Map<String, String>> getUserData() async {
    return {
      'name': await _secureStorage.read(key: _nameKey) ?? "",
      'email': await _secureStorage.read(key: _emailKey) ?? "",
      'phone': await _secureStorage.read(key: _phoneKey) ?? "",
    };
  }
}
