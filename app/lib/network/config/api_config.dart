class ApiConfig {
  //* Base URLs for different environments
  static const String IP = "192.168.56.1";

  static const String _baseUrlDev = 'http://10.0.2.2:5000';
  static const String _baseUrlStaging = 'https://staging-api.example.com';
  static const String _baseUrlProd = 'https://pillbin-v2.onrender.com';
  // 'https://pillbinv2-production.up.railway.app';

  static const String baseUrl2 = 'https://srv882174.hstgr.cloud';

  static const String agentURL = 'https://pillbin-v2-agent.onrender.com';
  // 'http://10.0.2.2:8000';
  // 'https://reportlangchainagent-production.up.railway.app';

  //* Current environment
  static const String currentEnvironment = 'dev';

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
  static const int connectTimeout = 60000;
  static const int receiveTimeout = 60000;
  static const int sendTimeout = 60000;
}
