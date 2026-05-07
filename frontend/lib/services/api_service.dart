import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/backend/parking_api_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';
  static String? token;
  static String? refreshToken;

  // Oturum sona erdiğinde çağrılacak callback (main_navigation veya login ekranı set eder)
  static Future<void> Function()? onSessionExpired;

  static Map<String, String> get _headers {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Refresh token ile yeni access token alır.
  /// Başarısız olursa onSessionExpired callback'ini tetikler.
  static Future<bool> _tryRefresh() async {
    if (refreshToken == null || refreshToken!.isEmpty) {
      debugPrint('[ApiService] Refresh token yok, oturum sona erdi.');
      onSessionExpired?.call();
      return false;
    }
    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        token = decoded['token'];
        refreshToken = decoded['refreshToken'];
        debugPrint('[ApiService] Token otomatik yenilendi.');
        return true;
      }
      debugPrint('[ApiService] Refresh başarısız (${resp.statusCode}), oturum sona erdi.');
      onSessionExpired?.call();
      return false;
    } catch (e) {
      debugPrint('[ApiService] Refresh HATA: $e');
      onSessionExpired?.call();
      return false;
    }
  }

  /// GET — 401 gelirse refresh dener, sonra tekrar gönderir.
  static Future<http.Response> _get(Uri uri) async {
    var resp = await http.get(uri, headers: _headers);
    if (resp.statusCode == 401) {
      final ok = await _tryRefresh();
      if (ok) resp = await http.get(uri, headers: _headers);
    }
    return resp;
  }

  /// POST — 401 gelirse refresh dener, sonra tekrar gönderir.
  static Future<http.Response> _post(Uri uri, String body) async {
    var resp = await http.post(uri, headers: _headers, body: body);
    if (resp.statusCode == 401) {
      final ok = await _tryRefresh();
      if (ok) resp = await http.post(uri, headers: _headers, body: body);
    }
    return resp;
  }

  // ─── AUTH ────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      debugPrint('LOGIN STATUS: ${resp.statusCode}');
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        token = decoded['token'];
        refreshToken = decoded['refreshToken'];
        return {'success': true, 'data': decoded};
      }
      return {'success': false, 'message': 'Giriş başarısız'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );
      if (resp.statusCode == 200 || resp.statusCode == 201) return {'success': true};
      return {'success': false, 'message': 'Kayıt başarısız'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static void logout() {
    token = null;
    refreshToken = null;
  }

  // ─── PARKING ─────────────────────────────────────────────────────────────

  static Future<List<ParkingApiModel>> getAllParkings() async {
    try {
      final resp = await http.get(Uri.parse('$baseUrl/parking/all'), headers: _headers);
      if (resp.statusCode == 200) {
        final dynamic decoded = jsonDecode(resp.body);
        if (decoded is List) {
          return decoded.map((e) => ParkingApiModel.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('getAllParkings HATA: $e');
      return [];
    }
  }

  static Future<List<int>> getOccupiedSpots(int parkingId) async {
    try {
      final resp = await _get(Uri.parse('$baseUrl/reservations/occupied-spots/$parkingId'));
      if (resp.statusCode == 200) return List<int>.from(jsonDecode(resp.body));
      return [];
    } catch (e) {
      return [];
    }
  }

  // ─── RESERVATION ─────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> createReservation({
    required int parkingId,
    required String plateNumber,
    required String startTime,
    required String endTime,
    int? selectedSpotIndex,
  }) async {
    try {
      final body = <String, dynamic>{
        'parkingId': parkingId,
        'plateNumber': plateNumber,
        'startTime': startTime,
        'endTime': endTime,
      };
      if (selectedSpotIndex != null) body['selectedSpotIndex'] = selectedSpotIndex;

      final resp = await _post(Uri.parse('$baseUrl/reservations'), jsonEncode(body));
      debugPrint('CREATE RES STATUS: ${resp.statusCode} BODY: ${resp.body}');
      if (resp.statusCode == 200) return {'success': true};
      return {'success': false, 'message': resp.body};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<List<dynamic>> getMyReservations() async {
    try {
      final resp = await _get(Uri.parse('$baseUrl/reservations'));
      debugPrint('GET RESERVATIONS: ${resp.statusCode}');
      if (resp.statusCode == 200) return jsonDecode(resp.body);
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> cancelReservation(int id) async {
    try {
      final resp = await http.delete(Uri.parse('$baseUrl/reservations/$id'), headers: _headers);
      return resp.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ─── QR ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getQrToken(int reservationId) async {
    try {
      debugPrint('getQrToken reservationId=$reservationId  token=${token?.substring(0, 20)}...');
      final resp = await _get(Uri.parse('$baseUrl/qr/token/$reservationId'));
      debugPrint('QR STATUS: ${resp.statusCode}  BODY: ${resp.body}');
      if (resp.statusCode == 200) return jsonDecode(resp.body) as Map<String, dynamic>;
      return null;
    } catch (e) {
      debugPrint('getQrToken HATA: $e');
      return null;
    }
  }

  // ─── WALLET ──────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getWalletBalance() async {
    try {
      final resp = await _get(Uri.parse('$baseUrl/wallet/balance'));
      debugPrint('WALLET BALANCE STATUS: ${resp.statusCode}');
      if (resp.statusCode == 200) return jsonDecode(resp.body) as Map<String, dynamic>;
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> depositWallet(double amount) async {
    try {
      debugPrint('depositWallet amount=$amount');
      final resp = await _post(
        Uri.parse('$baseUrl/wallet/deposit'),
        jsonEncode({'amount': amount}),
      );
      debugPrint('DEPOSIT STATUS: ${resp.statusCode}  BODY: ${resp.body}');
      if (resp.statusCode == 200) {
        if (resp.body.trim().isEmpty) return {'success': true};
        try {
          return {'success': true, 'data': jsonDecode(resp.body)};
        } catch (_) {
          return {'success': true};
        }
      }
      try {
        final err = jsonDecode(resp.body);
        return {
          'success': false,
          'message': err['error'] ?? err['message'] ?? 'Yükleme başarısız',
        };
      } catch (_) {
        return {'success': false, 'message': 'Yükleme başarısız (HTTP ${resp.statusCode})'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<List<dynamic>> getWalletHistory() async {
    try {
      final resp = await _get(Uri.parse('$baseUrl/wallet/history'));
      if (resp.statusCode == 200) return jsonDecode(resp.body);
      return [];
    } catch (e) {
      return [];
    }
  }
}
