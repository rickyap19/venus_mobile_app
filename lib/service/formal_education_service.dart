import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FormalEducationService {
  static const String baseUrl = 'https://10.0.2.2:50314'; // Ganti dengan base URL API Anda

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET - Get all education records
  static Future<List<Map<String, dynamic>>> getEducationRecords() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/PersonalData/creweducation'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody is Map<String, dynamic>) {
          if (responseBody['success'] == true && responseBody['data'] != null) {
            final List<dynamic> data = responseBody['data'];
            return data.map((item) => item as Map<String, dynamic>).toList();
          } else {
            throw Exception(responseBody['message'] ?? 'Failed to load education records');
          }
        }

        final List<dynamic> data = responseBody;
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load education records: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching education records: $e');
    }
  }

  // GET - Get education record by ID
  static Future<Map<String, dynamic>> getEducationRecordById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/PersonalData/creweducation/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody is Map<String, dynamic>) {
          if (responseBody['success'] == true && responseBody['data'] != null) {
            return responseBody['data'] as Map<String, dynamic>;
          } else {
            throw Exception(responseBody['message'] ?? 'Failed to load education record');
          }
        }

        return responseBody as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load education record: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching education record: $e');
    }
  }

  // POST - Create new education record
  static Future<Map<String, dynamic>> createEducationRecord(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/PersonalData/creweducation'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body);

        if (responseBody is Map<String, dynamic>) {
          if (responseBody['success'] == true) {
            return responseBody['data'] ?? responseBody;
          } else {
            throw Exception(responseBody['message'] ?? 'Failed to create education record');
          }
        }

        return responseBody as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create education record: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating education record: $e');
    }
  }

  // PUT - Update education record
  static Future<Map<String, dynamic>> updateEducationRecord(int id, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/PersonalData/creweducation/$id'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody is Map<String, dynamic>) {
          if (responseBody['success'] == true) {
            return responseBody['data'] ?? responseBody;
          } else {
            throw Exception(responseBody['message'] ?? 'Failed to update education record');
          }
        }

        return responseBody as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update education record: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating education record: $e');
    }
  }

  // DELETE - Delete education record
  static Future<void> deleteEducationRecord(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/PersonalData/creweducation/$id'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isNotEmpty) {
          final responseBody = json.decode(response.body);
          if (responseBody is Map<String, dynamic> && responseBody['success'] == false) {
            throw Exception(responseBody['message'] ?? 'Failed to delete education record');
          }
        }
        return;
      } else {
        throw Exception('Failed to delete education record: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting education record: $e');
    }
  }
}