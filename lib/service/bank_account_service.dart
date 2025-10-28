import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BankAccountService {
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

  // GET - Get all bank accounts
  static Future<List<Map<String, dynamic>>> getBankAccounts() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/PersonalData/bankaccount'),
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
            throw Exception(responseBody['message'] ?? 'Failed to load bank accounts');
          }
        }

        // Fallback for direct array response
        final List<dynamic> data = responseBody;
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load bank accounts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching bank accounts: $e');
    }
  }

  // GET - Get bank account by ID
  static Future<Map<String, dynamic>> getBankAccountById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/PersonalData/bankaccount/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        // Handle wrapped response structure
        if (responseBody is Map<String, dynamic>) {
          if (responseBody['success'] == true && responseBody['data'] != null) {
            return responseBody['data'] as Map<String, dynamic>;
          } else {
            throw Exception(responseBody['message'] ?? 'Failed to load bank account');
          }
        }

        return responseBody as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load bank account: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching bank account: $e');
    }
  }

  // POST - Create new bank account
  static Future<Map<String, dynamic>> createBankAccount(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/PersonalData/bankaccount'),
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
            throw Exception(responseBody['message'] ?? 'Failed to create bank account');
          }
        }

        return responseBody as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create bank account: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating bank account: $e');
    }
  }

  // PUT - Update bank account
  static Future<Map<String, dynamic>> updateBankAccount(int id, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/PersonalData/bankaccount/$id'),
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
            throw Exception(responseBody['message'] ?? 'Failed to update bank account');
          }
        }

        return responseBody as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update bank account: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating bank account: $e');
    }
  }

  // DELETE - Delete bank account
  static Future<void> deleteBankAccount(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/PersonalData/bankaccount/$id'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Success - check if there's a response body
        if (response.body.isNotEmpty) {
          final responseBody = json.decode(response.body);
          if (responseBody is Map<String, dynamic> && responseBody['success'] == false) {
            throw Exception(responseBody['message'] ?? 'Failed to delete bank account');
          }
        }
        return;
      } else {
        throw Exception('Failed to delete bank account: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting bank account: $e');
    }
  }
}