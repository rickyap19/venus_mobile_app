import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FamilyService {
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

  // GET - Get all family members
  static Future<List<Map<String, dynamic>>> getFamilyMembers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/PersonalData/crewfamily'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody is Map<String, dynamic>) {
          if (responseBody['success'] == true && responseBody['data'] != null) {
            final List<dynamic> data = responseBody['data'];
            return data.map((item) => item as Map<String, dynamic>).toList();
          } else {
            throw Exception(responseBody['message'] ?? 'Failed to load family members');
          }
        }

        final List<dynamic> data = responseBody;
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load family members: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching family members: $e');
    }
  }

  // GET - Get family member by ID
  static Future<Map<String, dynamic>> getFamilyMemberById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/PersonalData/crewfamily/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody is Map<String, dynamic>) {
          if (responseBody['success'] == true && responseBody['data'] != null) {
            return responseBody['data'] as Map<String, dynamic>;
          } else {
            throw Exception(responseBody['message'] ?? 'Failed to load family member');
          }
        }

        return responseBody as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load family member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching family member: $e');
    }
  }

  // POST - Create new family member
  static Future<Map<String, dynamic>> createFamilyMember(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/PersonalData/crewfamily'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body);

        if (responseBody is Map<String, dynamic>) {
          if (responseBody['success'] == true) {
            return responseBody['data'] ?? responseBody;
          } else {
            throw Exception(responseBody['message'] ?? 'Failed to create family member');
          }
        }

        return responseBody as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create family member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating family member: $e');
    }
  }

  // PUT - Update family member
  static Future<Map<String, dynamic>> updateFamilyMember(int id, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/PersonalData/crewfamily/$id'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody is Map<String, dynamic>) {
          if (responseBody['success'] == true) {
            return responseBody['data'] ?? responseBody;
          } else {
            throw Exception(responseBody['message'] ?? 'Failed to update family member');
          }
        }

        return responseBody as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update family member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating family member: $e');
    }
  }

  // DELETE - Delete family member
  static Future<void> deleteFamilyMember(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/PersonalData/crewfamily/$id'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isNotEmpty) {
          final responseBody = json.decode(response.body);
          if (responseBody is Map<String, dynamic> && responseBody['success'] == false) {
            throw Exception(responseBody['message'] ?? 'Failed to delete family member');
          }
        }
        return;
      } else {
        throw Exception('Failed to delete family member: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting family member: $e');
    }
  }
}