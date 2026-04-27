import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/backend/parking_api_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';

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

      print("LOGIN STATUS: ${response.statusCode}");
      print("LOGIN BODY: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        token = decoded['token'];

        return {'success': true, 'data': decoded};
      }

      return {'success': false, 'message': 'Giriş başarısız'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ---------------------------
  // REGISTER
  // ---------------------------
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      }

      return {'success': false, 'message': 'Kayıt başarısız'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ---------------------------
  // PARKING LIST
  // ---------------------------
 
 // 1. TÜM OTOPARKLARI GETİREN METOD
 static Future<List<ParkingApiModel>> getAllParkings() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/parking/all'),
        headers: _headers,
      );

      debugPrint('STATUS: ' + response.statusCode.toString());
      debugPrint('BODY: ' + response.body);

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded.map((e) => ParkingApiModel.fromJson(e as Map<String, dynamic>)).toList();
        }
        return [];
      }
      return [];
    } catch (e) {
      debugPrint('HATA: ' + e.toString());
      return [];
    }
  }

  // 2. DOLU YERLERİ GETİREN METOD (Hata veren yer burasıydı, dışarı aldık)
  static Future<List<int>> getOccupiedSpots(int parkingId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/reservations/occupied-spots/$parkingId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return List<int>.from(jsonDecode(response.body));
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
    required int parkingId,
    required String plateNumber,
    required String startTime,
    required String endTime,
    int? selectedSpotIndex, // Haritadan seçilen park yeri kutucuğu eklendi
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservations'),
        headers: _headers,
        body: jsonEncode({
          'parkingId': parkingId,
          'plateNumber': plateNumber,
          'startTime': startTime,
          'endTime': endTime,
          // Eğer haritadan bir kutucuk seçildiyse bunu backend'e gönderiyoruz
          if (selectedSpotIndex != null) 'selectedSpotIndex': selectedSpotIndex, 
        }),
      );

      print("RES STATUS: ${response.statusCode}");
      print("RES BODY: ${response.body}");

      if (response.statusCode == 200) {
        return {'success': true};
      }

      return {'success': false, 'message': response.body};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ---------------------------
  // GET MY RESERVATIONS
  // ---------------------------
  static Future<List<dynamic>> getMyReservations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservations'),
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
  // CANCEL RESERVATION
  // ---------------------------
  static Future<bool> cancelReservation(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/reservations/$id'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ---------------------------
  // LOGOUT
  // ---------------------------
  static void logout() {
    token = null;
  }
}