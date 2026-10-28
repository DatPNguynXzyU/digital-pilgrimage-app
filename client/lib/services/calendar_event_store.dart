import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/calendar_event.dart';
import 'auth_service.dart';

class CalendarEventStore {
  static final changes = ValueNotifier<int>(0);
  static const String _storageKey = 'personal_calendar_events_v1';
  final http.Client? client;
  CalendarEventStore({this.client});

  Future<http.Response> _request(
    String method,
    String path,
    String token, [
    Map<String, dynamic>? data,
  ]) async {
    final request = http.Request(
      method,
      Uri.parse('${ApiConfig.baseUrl}/calendar-events$path'),
    );
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    if (data != null) request.body = jsonEncode(data);
    final transport = client ?? http.Client();
    try {
      final response = await transport
          .send(request)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      }
      return response;
    } finally {
      if (client == null) transport.close();
    }
  }

  Map<String, dynamic> _body(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Không thể đồng bộ lịch.');
    }
    return body;
  }

  Future<List<CalendarEvent>> load() async {
    final token = await AuthService().getToken();
    if (token != null && token.isNotEmpty) {
      final body = _body(await _request('GET', '', token));
      return (body['data'] as List)
          .map((item) => CalendarEvent.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null || encoded.isEmpty) return [];
    final decoded = jsonDecode(encoded);
    if (decoded is! List) {
      throw const FormatException('Dữ liệu lịch cá nhân không hợp lệ.');
    }
    return decoded
        .map((item) => CalendarEvent.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveGuest(List<CalendarEvent> events) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(events.map((event) => event.toJson()).toList()),
    );
    if (!saved) throw StateError('Không thể lưu lịch cá nhân trên thiết bị.');
  }

  Future<void> upsert(CalendarEvent event) async {
    final token = await AuthService().getToken();
    if (token != null && token.isNotEmpty) {
      final path = '/${Uri.encodeComponent(event.id)}';
      final existing = await _request('GET', path, token);
      if (existing.statusCode == 404) {
        _body(await _request('POST', '', token, event.toJson()));
      } else {
        _body(existing);
        _body(await _request('PUT', path, token, event.toJson()));
      }
      changes.value++;
      return;
    }
    final events = await load();
    final index = events.indexWhere((item) => item.id == event.id);
    if (index == -1) {
      events.add(event);
    } else {
      events[index] = event;
    }
    await _saveGuest(events);
    changes.value++;
  }

  Future<void> delete(String id) async {
    final token = await AuthService().getToken();
    if (token != null && token.isNotEmpty) {
      _body(await _request('DELETE', '/${Uri.encodeComponent(id)}', token));
      changes.value++;
      return;
    }
    final events = await load();
    events.removeWhere((event) => event.id == id);
    await _saveGuest(events);
    changes.value++;
  }
}
