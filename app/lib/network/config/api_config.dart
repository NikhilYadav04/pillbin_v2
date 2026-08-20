class ApiConfig {
  //* Flip this single line to point the whole app at local or deployed
  //* backends — both the Node server and the agno agent follow it.
  //*   'dev'  -> emulator localhost
  //*   'prod' -> Render
  static const String currentEnvironment = 'dev';

  static const bool _isProd = currentEnvironment == 'prod';

  //* Node server
  static const String _serverDev = 'http://10.0.2.2:5000';
  static const String _serverProd = 'https://pillbin-v2.onrender.com';

  //* agno agent
  static const String _agentDev = 'http://10.0.2.2:8000';
  static const String _agentProd = 'https://pillbin-v2-agno-agent.onrender.com';

  static String get baseUrl => _isProd ? _serverProd : _serverDev;

  static String get agentBaseUrl => _isProd ? _agentProd : _agentDev;

  //* Deprecated LangChain agent — only the health_ai screens still call this
  static const String agentURL = 'https://pillbin-v2-agent.onrender.com';

  //* Render free instances cold start, and the agent's first reply also warms
  //* Chroma, so this is deliberately longer than the server timeouts
  static const int agentReceiveTimeout = 90000;

  static const int connectTimeout = 60000;
  static const int receiveTimeout = 60000;
  static const int sendTimeout = 60000;
}
