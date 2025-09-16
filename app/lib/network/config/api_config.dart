class ApiConfig {
  //* Base URLs for different environments
  static const String IP = "192.168.56.1";

  static const String _baseUrlDev = 'https://dev-api.example.com';
  static const String _baseUrlStaging = 'https://staging-api.example.com';
  static const String _baseUrlProd = 'https://attendance-track-prisma.onrender.com';

  static const String baseUrl2 = 'https://srv882174.hstgr.cloud';

  //* Current environment
  static const String currentEnvironment = 'prod';

  static String get baseUrl {
    switch (currentEnvironment) {
      case 'dev':
        return _baseUrlDev;
      case 'staging':
        return _baseUrlStaging;
      case 'prod':
        return _baseUrlProd;
      default:
        return _baseUrlDev;
    }
  }

  //* API Configuration
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
}
