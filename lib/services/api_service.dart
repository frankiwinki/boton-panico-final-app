// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'https://backend.botonph.com/api';

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      return true;
    }

    return false;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<http.Response> getConToken(String endpoint) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/$endpoint');

    return http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<http.Response> postConToken(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/$endpoint');

    return http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
  }

  Future<bool> registrarUsuario(Map<String, dynamic> data) async {
    final response = await postConToken('register', data);
    return response.statusCode == 201;
  }

  Future<bool> enviarEmergencia(
    String coordenadas, {
    required String tipo,
    required String descripcion,
  }) async {
    final response = await postConToken('emergencies', {
      'coordenadas': coordenadas,
      'tipo': tipo,
      'descripcion': descripcion,
    });

    return response.statusCode == 201;
  }

  Future<List<Map<String, dynamic>>> getDepartamentos() async {
    final response = await getConToken('departamentos');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getProvincias(String depId) async {
    final response = await getConToken('provincias/$depId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getDistritos(String provId) async {
    final response = await getConToken('distritos/$provId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }
}
