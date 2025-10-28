import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentService {
  static const String baseUrl = 'https://10.0.2.2:50314/api';

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

  // Get all documents
  static Future<List<Map<String, dynamic>>> getDocuments() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/PersonalData/document'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
        return [];
      } else {
        throw Exception('Failed to load documents: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching documents: $e');
    }
  }

  static Future<bool> saveDocument(Map<String, dynamic> documentData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/PersonalData/document'),
        headers: headers,
        body: json.encode(documentData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Document saved successfully');
        return true;
      } else {
        print('❌ Failed to save document: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to save document: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error saving document: $e');
      throw Exception('Error saving document: $e');
    }
  }

  /// Update document (PUT)
  static Future<bool> updateDocument(Map<String, dynamic> documentData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/PersonalData/document'),
        headers: headers,
        body: json.encode(documentData),
      );

      if (response.statusCode == 200) {
        print('✅ Document updated successfully');
        return true;
      } else {
        print('❌ Failed to update document: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to update document: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating document: $e');
      throw Exception('Error updating document: $e');
    }
  }// Delete document
  static Future<bool> deleteDocument(String documentId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/PersonalData/document/$documentId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete document: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting document: $e');
    }
  }

  // Get document types
  static Future<List<String>> getDocumentTypes() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/PersonalData/document/types'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data'] is List) {
          return List<String>.from(data['data']);
        }
        return [];
      } else {
        // Default document types if API doesn't provide them
        return [
          'Passport',
          'Seaman Book',
          'BPJS Kesehatan',
          'BPJS Ketenagakerjaan',
          'SID',
          'KTP',
          'Driver License',
          'Others',
        ];
      }
    } catch (e) {
      // Return default types on error
      return [
        'Passport',
        'Seaman Book',
        'BPJS Kesehatan',
        'BPJS Ketenagakerjaan',
        'SID',
        'KTP',
        'Driver License',
        'Others',
      ];
    }
  }
}