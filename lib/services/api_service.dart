// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// --- SỬA LỖI: IMPORT TASK MODEL ---
import '../models/task.dart'; // <-- Đảm bảo đường dẫn này đúng

class ApiService {
  static const String baseUrl = "http://10.0.2.2:5000/api"; // emulator IP

  Future<dynamic> get(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final res = await http.get(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    return _handleResponse(res);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final res = await http.post(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );
    return _handleResponse(res);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final res = await http.put(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );
    return _handleResponse(res);
  }

  // Thêm phương thức DELETE
  Future<dynamic> delete(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final res = await http.delete(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    return _handleResponse(res);
  }

  // --- SỬA LỖI: CHUYỂN 'LIST<DYNAMIC>' THÀNH 'LIST<TASK>' ---
  Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final res = await http.get(
      Uri.parse("$baseUrl/tasks"),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    // Xử lý và chuyển đổi kiểu dữ liệu
    final data = _handleResponse(res);
    if (data is List) {
      // Dùng map để convert từng item trong list thành một Task object
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      return [];
    }
  }
  // --- HẾT PHẦN SỬA LỖI ---

  dynamic _handleResponse(http.Response res) {
    // Sửa lỗi: Check body rỗng trước khi decode
    if (res.body.isEmpty) {
      // Nếu body rỗng nhưng status 2xx (vd: 204 No Content), trả về null
      if (res.statusCode >= 200 && res.statusCode < 300) return null;
      // Nếu body rỗng và lỗi, ném ra lỗi chung
      throw Exception('Lỗi: Phản hồi rỗng từ server');
    }

    final data = json.decode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return data;

    // Ném ra lỗi cụ thể từ message của server
    throw Exception(data['message'] ?? 'Lỗi server không xác định');
  }
}
