import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/backend/parking_api_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';

  // 🔥 TEK TOKEN
  static String? token;

  // ---------------------------
  // HEADERS
  // ---------------------------
  static Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null && token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // ---------------------------
  // LOGIN
  // ---------------------------
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        token = decoded['token']; // 🔥 TOKEN KAYDEDİLİYOR

        return {
          'success': true,
          'message': 'Giriş başarılı',
          'data': decoded,
        };
      }

      return {
        'success': false,
        'message': 'Email veya şifre hatalı',
      };

    } catch (e) {
      return {
        'success': false,
        'message': 'Sunucu hatası: $e',
      };
    }
  }

  // ---------------------------
  // REGISTER
  // ---------------------------
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String role = 'USER',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Kayıt başarılı',
        };
      }

      return {
        'success': false,
        'message': 'Kayıt başarısız',
      };

    } catch (e) {
      return {
        'success': false,
        'message': 'Sunucu hatası: $e',
      };
    }
  }

  // ---------------------------
  // PARKING LIST
  // ---------------------------
  static Future<List<ParkingApiModel>> getAllParkings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/parking/all'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(response.body);

        return decoded
            .map((e) => ParkingApiModel.fromJson(e))
            .toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  // ---------------------------
  // CREATE RESERVATION
  // ---------------------------
  static Future<Map<String, dynamic>> createReservation({
    required int parkingSpotId,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservation/create'),
        headers: _headers,
        body: jsonEncode({
          'parkingSpotId': parkingSpotId,
          'startTime': startTime,
          'endTime': endTime,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Rezervasyon oluşturuldu',
        };
      }

      return {
        'success': false,
        'message': 'Rezervasyon başarısız',
      };

    } catch (e) {
      return {
        'success': false,
        'message': 'Sunucu hatası: $e',
      };
    }
  }

  // ---------------------------
  // GET RESERVATIONS
  // ---------------------------
  static Future<List<dynamic>> getReservations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservation/all'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  // ---------------------------
  // LOGOUT
  // ---------------------------
  static void logout() {
    token = null;
  }
}