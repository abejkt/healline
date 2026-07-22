class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://34.50.106.220:8443/rest/v1';
//  static const String apiKey = 'sb_publishable_0usGoAC2P6E6nhBGvqM3Xj_KXPDZaod';
  static const String apiKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzc5Mjg5MTExLCJleHAiOjE5MzY5NjkxMTF9.AGU9FqRFP-uPjPqvMSeHTmD22GWLecz_qAa5B6fL1Hg'
  static const String jwtToken = 'AGNDGFwD3cdj49Je3FHJIV8YQN7R1Cwmgc+GNa6Q';

  static Map<String, String> get headers => {
        'apikey': '$apiKey',
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      };
}
