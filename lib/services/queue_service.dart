import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/active_queue_status.dart';
import '../models/queue_ticket.dart';
import 'api_config.dart';

class QueueService {
  Future<ActiveQueueStatus?> fetchActiveQueue(String doctorName) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/active_queue_status?doctor_name=eq.$doctorName&select=*'),
      headers: ApiConfig.headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.isNotEmpty ? ActiveQueueStatus.fromMap(data.first) : null;
    } else {
      throw Exception('Failed to load active queue: ${response.statusCode}');
    }
  }

  Future<List<UpcomingQueue>> fetchUpcomingQueues(String userId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/upcoming_queues?user_id=eq.$userId&select=*'),
      headers: ApiConfig.headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => UpcomingQueue.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load upcoming queues: ${response.statusCode}');
    }
  }

  Future<UpcomingQueue> createUpcomingQueue(Map<String, dynamic> queueData) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/upcoming_queues'),
      headers: {
        ...ApiConfig.headers,
        'Prefer': 'return=representation',
      },
      body: json.encode(queueData),
    );

    if (response.statusCode == 201) {
      final List<dynamic> data = json.decode(response.body);
      return UpcomingQueue.fromMap(data.first);
    } else {
      throw Exception('Failed to create queue: ${response.statusCode}');
    }
  }
}
