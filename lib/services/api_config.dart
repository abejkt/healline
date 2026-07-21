class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://34.50.106.220:8443/rest/v1';
  static const String apiKey = 'sb_publishable_0usGoAC2P6E6nhBGvqM3Xj_KXPDZaod';

  static Map<String, String> get headers => {
        'apikey': apiKey,
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };
}
