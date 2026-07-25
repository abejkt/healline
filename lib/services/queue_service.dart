import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/active_queues.dart';
import '../models/queue_ticket.dart';
import 'api_config.dart';

class QueueService {
  Future<ActiveQueue?> fetchActiveQueue(String doctorName) async {
    final encodedName = Uri.encodeComponent(doctorName);
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/active_queues?doctor_name=eq.$encodedName&select=*'),
      headers: ApiConfig.headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.isNotEmpty ? ActiveQueue.fromMap(data.first) : null;
    } else {
      throw Exception('Failed to load active queue: ${response.statusCode}');
    }
  }

  Future<List<ActiveQueue>> fetchActiveQueuesByDate(String dateIso) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/active_queues?date=eq.$dateIso&select=*'),
      headers: ApiConfig.headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ActiveQueue.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load active queues for date: ${response.statusCode}');
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

  Future<void> updateLastTicket(String doctorName, String newTicketNumber) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/active_queues?doctor_name=eq.$doctorName'),
      headers: ApiConfig.headers,
      body: json.encode({
        'last_ticket_number': newTicketNumber,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update last ticket: ${response.statusCode}');
    }
  }

  Future<void> cancelQueue(String ticketNumber) async {
    // 1. Update status to 'batal' in visits table
    final visitResponse = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/visits?queue_code=eq.$ticketNumber'),
      headers: ApiConfig.headers,
      body: json.encode({'status': 'batal'}),
    );

    if (visitResponse.statusCode != 200 && visitResponse.statusCode != 204) {
      throw Exception('Failed to update visit status: ${visitResponse.statusCode}');
    }

    // 2. Delete from upcoming_queues table
    final deleteResponse = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/upcoming_queues?ticket_number=eq.$ticketNumber'),
      headers: ApiConfig.headers,
    );

    if (deleteResponse.statusCode != 200 && deleteResponse.statusCode != 204) {
      throw Exception('Failed to delete upcoming queue: ${deleteResponse.statusCode}');
    }
  }
}
