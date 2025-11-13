// lib/services/auth_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart'; // Import model User
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final ApiService _api = ApiService();
  String? _token;
  User? _currentUser;
  bool _isLoading = false;

  bool get isAuthenticated => _token != null;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  // --- GETTER ĐÃ SỬA VÀ XÁC NHẬN ---
  
  // Lấy 'id' từ model User
  String? get userId => _currentUser?.id;

  // Lấy 'role' từ model User
  String? get userRole => _currentUser?.role;

  // Lấy 'groupId' từ model User (Đây là dòng đã sửa)
  String? get groupId => _currentUser?.groupId; 

  // --- HẾT PHẦN SỬA ---

  AuthService() {
    tryAutoLogin();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('token');
    if (stored == null) return;
    _token = stored;
    await _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await _api.get('auth/me');
      _currentUser = User.fromJson(response);
      notifyListeners();
    } catch (e) {
      await logout();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.post('auth/login', {
        'email': email,
        'password': password,
      });
      _token = res['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await _fetchProfile(); 
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    await _api.post('auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _token = null;
    _currentUser = null;
    notifyListeners();
  }
}