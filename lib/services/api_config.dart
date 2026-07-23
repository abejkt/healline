class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://34.50.106.220:8443/rest/v1';
  static const String apiKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzc5Mjg5MTExLCJleHAiOjE5MzY5NjkxMTF9.AGU9FqRFP-uPjPqvMSeHTmD22GWLecz_qAa5B6fL1Hg';

  static Map<String, String> get headers => {
        'apikey': apiKey,
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };
}
