// services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'https://backend.sihuasresponde.com/api';

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'num_doc': email, 'password': password}),
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

    // ✅ VALIDACIÓN: Solo agregar header si hay token válido
    Map<String, String> headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return http.get(url, headers: headers);
  }

  Future<http.Response> postConToken(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/$endpoint');

    // ✅ VALIDACIÓN: Solo agregar header si hay token válido
    Map<String, String> headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );
  }

  Future<http.StreamedResponse> postMultipartConToken(
    String endpoint, {
    required Map<String, String> fields,
    File? imagen,
  }) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/$endpoint');

    var request = http.MultipartRequest('POST', url);
    
    // ✅ VALIDACIÓN: Solo agregar header si hay token válido
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Campos normales
    request.fields.addAll(fields);

    // Adjuntar imagen si existe
    if (imagen != null) {
      request.files.add(
        await http.MultipartFile.fromPath('imagen', imagen.path),
      );
    }

    print("📌 Campos a enviar: $fields");
    if (imagen != null) {
      print("📸 Imagen path: ${imagen.path}");
    }

    return request.send();
  }

  Future<bool> registrarUsuario(Map<String, dynamic> data) async {
    final response = await postConToken('registerUser', data);
    return response.statusCode == 201;
  }

  Future<bool> enviarEmergencia(
    String coordenadas, {
    required String tipo,
    required String descripcion,
    File? imagen,
  }) async {
    final response = await postMultipartConToken(
      "emergencies",
      fields: {
        "coordenadas": coordenadas,
        "tipo_emergencia": tipo, // 👈 igual que en tu backend
        "descripcion": descripcion,
      },
      imagen: imagen,
    );

    return response.statusCode == 201;
  }

  Future<List<Map<String, dynamic>>> getDepartamentos() async {
    final response = await getConToken('ubigeo/departamentos');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getProvincias(String depId) async {
    final response = await getConToken('ubigeo/provincias/$depId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getDistritos(String provId) async {
    final response = await getConToken('ubigeo/distritos/$provId');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  Future<Map<String, dynamic>> consultarDni(String dni) async {
    final response = await postConToken('consultarDni', {'dni': dni});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Error al consultar DNI: ${response.statusCode}");
    }
  }
}