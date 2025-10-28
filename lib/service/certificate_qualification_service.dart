import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CertificateQualificationService {
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

  // GET - Get certificate names from Certificate API
  static Future<List<Map<String, dynamic>>> getCertificateNames() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/Certificate'),
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
            throw Exception(responseBody['message'] ?? 'Failed to load certificate names');
          }
        }

        // Fallback for direct array response
        final List<dynamic> data = responseBody;
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load certificate names: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching certificate names: $e');
    }
  }

  // GET - Get all certificates
  static Future<List<Map<String, dynamic>>> getCertificates() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/PersonalData/crewcertificatequalification'),
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
            throw Exception(responseBody['message'] ?? 'Failed to load certificates');
          }
        }

        // Fallback for direct array response
        final List<dynamic> data = responseBody;
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load certificates: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching certificates: $e');
    }
  }

  // GET - Get certificate by ID
  static Future<Map<String, dynamic>> getCertificateById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/PersonalData/crewcertificatequalification/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        // Handle wrapped response structure
        if (responseBody is Map<String, dynamic>) {
          if (responseBody['success'] == true && responseBody['data'] != null) {
            return responseBody['data'] as Map<String, dynamic>;
          } else {
            throw Exception(responseBody['message'] ?? 'Failed to load certificate');
          }
        }

        return responseBody as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load certificate: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching certificate: $e');
    }
  }

  // POST - Create new certificate
  static Future<Map<String, dynamic>> createCertificate(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/PersonalData/crewcertificatequalification'),
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
            throw Exception(responseBody['message'] ?? 'Failed to create certificate');
          }
        }

        return responseBody as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create certificate: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating certificate: $e');
    }
  }

  // PUT - Update certificate
  static Future<Map<String, dynamic>> updateCertificate(int id, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/PersonalData/crewcertificatequalification/$id'),
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
            throw Exception(responseBody['message'] ?? 'Failed to update certificate');
          }
        }

        return responseBody as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update certificate: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating certificate: $e');
    }
  }

  // DELETE - Delete certificate
  static Future<void> deleteCertificate(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/PersonalData/crewcertificatequalification/$id'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Success - check if there's a response body
        if (response.body.isNotEmpty) {
          final responseBody = json.decode(response.body);
          if (responseBody is Map<String, dynamic> && responseBody['success'] == false) {
            throw Exception(responseBody['message'] ?? 'Failed to delete certificate');
          }
        }
        return;
      } else {
        throw Exception('Failed to delete certificate: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting certificate: $e');
    }
  }
}