import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PersonalDataService {
  static const String baseUrl = 'https://10.0.2.2:50314/api';
  static const String _keyToken = 'auth_token';

  // Helper method to get token from SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // Helper method to get headers with token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET Countries
  static Future<List<Map<String, dynamic>>> getCountries() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/Country'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          return data.cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        throw Exception('Failed to load countries: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading countries: $e');
      rethrow;
    }
  }

  // GET User Profile
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/User/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return jsonResponse['data'];
        }
        return null;
      } else {
        throw Exception('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading user profile: $e');
      rethrow;
    }
  }

  // GET Complete Personal Data
  static Future<Map<String, dynamic>?> getCompletePersonalData() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/PersonalData/complete'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return jsonResponse['data'];
        }
        return null;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load complete personal data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading complete personal data: $e');
      rethrow;
    }
  }

  // GET Personal Data
  static Future<Map<String, dynamic>?> getPersonalData() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/PersonalData/personal'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        // No data found, return null
        return null;
      } else {
        throw Exception('Failed to load personal data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading personal data: $e');
      rethrow;
    }
  }

  // POST/PUT Personal Data
  static Future<void> savePersonalData(Map<String, dynamic> data, {bool isUpdate = false}) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/PersonalData/personal');

      http.Response response;
      if (isUpdate) {
        response = await http.put(url, headers: headers, body: json.encode(data));
      } else {
        response = await http.post(url, headers: headers, body: json.encode(data));
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to save personal data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error saving personal data: $e');
      rethrow;
    }
  }

  // GET Address
  static Future<List<Map<String, dynamic>>> getAddresses() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/PersonalData/address'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load addresses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading addresses: $e');
      rethrow;
    }
  }

  // POST/PUT Address
  static Future<void> saveAddress(Map<String, dynamic> data, {bool isUpdate = false}) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/PersonalData/address');

      http.Response response;
      if (isUpdate) {
        response = await http.put(url, headers: headers, body: json.encode(data));
      } else {
        response = await http.post(url, headers: headers, body: json.encode(data));
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to save address: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error saving address: $e');
      rethrow;
    }
  }

  // GET Measurement
  static Future<Map<String, dynamic>?> getMeasurement() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/PersonalData/measurement'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load measurement: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading measurement: $e');
      rethrow;
    }
  }

  // POST/PUT Measurement
  static Future<void> saveMeasurement(Map<String, dynamic> data, {bool isUpdate = false}) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/PersonalData/measurement');

      http.Response response;
      if (isUpdate) {
        response = await http.put(url, headers: headers, body: json.encode(data));
      } else {
        response = await http.post(url, headers: headers, body: json.encode(data));
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to save measurement: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error saving measurement: $e');
      rethrow;
    }
  }

  // GET Next of Kin
  static Future<Map<String, dynamic>?> getNextOfKin() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/PersonalData/nextofkin'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load next of kin: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading next of kin: $e');
      rethrow;
    }
  }

  // POST/PUT Next of Kin
  static Future<void> saveNextOfKin(Map<String, dynamic> data, {bool isUpdate = false}) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/PersonalData/nextofkin');

      http.Response response;
      if (isUpdate) {
        response = await http.put(url, headers: headers, body: json.encode(data));
      } else {
        response = await http.post(url, headers: headers, body: json.encode(data));
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to save next of kin: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error saving next of kin: $e');
      rethrow;
    }
  }

  // Upload Photo (you'll need to implement multipart request)
  static Future<String> uploadPhoto(String filePath, String type) async {
    try {
      final headers = await _getHeaders();
      headers.remove('Content-Type'); // Will be set automatically for multipart

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/PersonalData/upload-photo'),
      );

      request.headers.addAll(headers);
      request.fields['type'] = type; // 'photo' or 'visa'
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(responseBody);
        return jsonResponse['path'] ?? '';
      } else {
        throw Exception('Failed to upload photo: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading photo: $e');
      rethrow;
    }
  }

  // Upload KTP
  static Future<String> uploadKTP(String filePath) async {
    try {
      final headers = await _getHeaders();
      headers.remove('Content-Type');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/PersonalData/upload-ktp'),
      );

      request.headers.addAll(headers);
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(responseBody);
        return jsonResponse['path'] ?? '';
      } else {
        throw Exception('Failed to upload KTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading KTP: $e');
      rethrow;
    }
  }
}