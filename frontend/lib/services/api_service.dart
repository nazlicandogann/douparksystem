import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/backend/parking_api_model.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8080/api';
  static String? token;

  static Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null && token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static dynamic _decodeBody(http.Response response) {
    try {
      return response.body.isNotEmpty ? jsonDecode(response.body) : {};
    } catch (_) {
      return response.body;
    }
  }

  static Map<String, dynamic> _successResponse(
    dynamic decoded,
    String defaultMessage,
  ) {
    if (decoded is Map<String, dynamic>) {
      final receivedToken =
          decoded['token'] ??
          decoded['accessToken'] ??
          decoded['access_token'] ??
          decoded['jwt'];

      if (receivedToken != null &&
          receivedToken.toString().isNotEmpty) {
        token = receivedToken.toString();
      }

      return {
        'success': true,
        'message': decoded['message'] ?? defaultMessage,
        'data': decoded,
      };
    }

    return {
      'success': true,
      'message': decoded.toString().isNotEmpty
          ? decoded.toString()
          : defaultMessage,
      'data': decoded,
    };
  }

  static Map<String, dynamic> _errorResponse(
    dynamic decoded,
    int statusCode,
    String defaultMessage,
  ) {
    if (decoded is Map<String, dynamic>) {
      return {
        'success': false,
        'message': decoded['message'] ??
            decoded['error'] ??
            decoded['details'] ??
            '$defaultMessage ($statusCode)',
        'data': decoded,
      };
    }

    return {
      'success': false,
      'message': decoded.toString().isNotEmpty
          ? decoded.toString()
          : '$defaultMessage ($statusCode)',
    };
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
        Uri.parse('$baseUrl/auth/login2'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final decoded = _decodeBody(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _successResponse(decoded, 'Giriş başarılı');
      }

      return _errorResponse(decoded, response.statusCode, 'Giriş başarısız');
    } catch (e) {
      return {
        'success': false,
        'message': 'Sunucuya bağlanılamadı: $e',
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

      final decoded = _decodeBody(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': decoded is Map<String, dynamic>
              ? (decoded['message'] ?? 'Kayıt başarılı')
              : decoded.toString().isNotEmpty
                  ? decoded.toString()
                  : 'Kayıt başarılı',
          'data': decoded,
        };
      }

      return _errorResponse(decoded, response.statusCode, 'Kayıt başarısız');
    } catch (e) {
      return {
        'success': false,
        'message': 'Sunucuya bağlanılamadı: $e',
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
        final decoded = _decodeBody(response);

        List<dynamic> rawList = [];

        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          rawList = decoded['data'] as List<dynamic>;
        }

        return rawList
            .map((e) => ParkingApiModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<ParkingApiModel>> getAllParking() async {
    return getAllParkings();
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

      final decoded = _decodeBody(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': decoded is Map<String, dynamic>
              ? (decoded['message'] ?? 'Rezervasyon oluşturuldu')
              : decoded.toString().isNotEmpty
                  ? decoded.toString()
                  : 'Rezervasyon oluşturuldu',
          'data': decoded,
        };
      }

      return _errorResponse(
        decoded,
        response.statusCode,
        'Rezervasyon başarısız',
      );
    } catch (e) {
      return {
        'success': false,
        'message': 'Sunucuya bağlanılamadı: $e',
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
        final decoded = _decodeBody(response);

        if (decoded is List) {
          return decoded;
        }

        if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          return decoded['data'];
        }
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  static void logout() {
    token = null;
  }
}