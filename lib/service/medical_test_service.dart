import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MedicalTestService {
  static const String baseUrl = 'https://10.0.2.2:50314';

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

  // GET - Get all medical tests
  static Future<List<Map<String, dynamic>>> getMedicalTests() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/PersonalData/crewmedicaltest'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        // Handle wrapped response structure
        if (responseBody is Map<String, dynamic>) {
          if (responseBody['success'] == true && responseBody['data'] != null) {
            final List<dynamic> data = responseBody['data'];
            return data.map((item) => item as Map<String, dynamic>).toList();
          } else {
            throw Exception(responseBody['message'] ?? 'Failed to load medical tests');
          }
        }

        // Fallback for direct array response
        final List<dynamic> data = responseBody;
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load medical tests: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching medical tests: $e');
    }
  }

  // GET - Get medical test by ID
  static Future<Map<String, dynamic>> getMedicalTestById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/PersonalData/crewmedicaltest/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        // Handle wrapped response structure
        if (responseBody is Map<String, dynamic>) {
          if (responseBody['success'] == true && responseBody['data'] != null) {
            return responseBody['data'] as Map<String, dynamic>;
          } else {
            throw Exception(responseBody['message'] ?? 'Failed to load medical test');
          }
        }

        return responseBody as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load medical test: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching medical test: $e');
    }
  }

  // POST - Create new medical test
  static Future<Map<String, dynamic>> createMedicalTest(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/PersonalData/crewmedicaltest'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body);

        // Handle wrapped response structure
        if (responseBody is Map<String, dynamic>) {
          if (responseBody['success'] == true) {
            return responseBody['data'] ?? responseBody;
          } else {
            throw Exception(responseBody['message'] ?? 'Failed to create medical test');
          }
        }

        return responseBody as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create medical test: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating medical test: $e');
    }
  }

  // PUT - Update medical test
  static Future<Map<String, dynamic>> updateMedicalTest(int id, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/PersonalData/crewmedicaltest/$id'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        // Handle wrapped response structure
        if (responseBody is Map<String, dynamic>) {
          if (responseBody['success'] == true) {
            return responseBody['data'] ?? responseBody;
          } else {
            throw Exception(responseBody['message'] ?? 'Failed to update medical test');
          }
        }

        return responseBody as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update medical test: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating medical test: $e');
    }
  }

  // DELETE - Delete medical test
  static Future<void> deleteMedicalTest(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/PersonalData/crewmedicaltest/$id'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Success - check if there's a response body
        if (response.body.isNotEmpty) {
          final responseBody = json.decode(response.body);
          if (responseBody is Map<String, dynamic> && responseBody['success'] == false) {
            throw Exception(responseBody['message'] ?? 'Failed to delete medical test');
          }
        }
        return;
      } else {
        throw Exception('Failed to delete medical test: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting medical test: $e');
    }
  }
}