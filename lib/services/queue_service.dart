import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/active_queue_status.dart';
import '../models/queue_ticket.dart';
import 'api_config.dart';

class QueueService {
  Future<ActiveQueueStatus?> fetchActiveQueue(String ticketNumber) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/active_queue_status?ticket_number=eq.$ticketNumber&select=*'),
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

  Future<QueueTicket?> fetchTicket(String ticketNumber) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/queue_tickets?ticket_number=eq.$ticketNumber&select=*'),
      headers: ApiConfig.headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.isNotEmpty ? QueueTicket.fromMap(data.first) : null;
    } else {
      throw Exception('Failed to load ticket: ${response.statusCode}');
    }
  }

  Future<QueueTicket> createQueueTicket(Map<String, dynamic> queueData) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/queue_tickets'),
      headers: {
        ...ApiConfig.headers,
        'Prefer': 'return=representation',
      },
      body: json.encode(queueData),
    );

    if (response.statusCode == 201) {
      final List<dynamic> data = json.decode(response.body);
      return QueueTicket.fromMap(data.first);
    } else {
      throw Exception('Failed to create queue ticket: ${response.statusCode}');
    }
  }
}
