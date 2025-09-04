import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart'; // <-- Importa tu service

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService apiService = ApiService(); // <-- instancia del servicio
  UserProfile? perfil;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    try {
      final response = await apiService.getConToken('profile');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          perfil = UserProfile.fromJson(json);
          cargando = false;
        });
      } else {
        setState(() => cargando = false);
        _mostrarError('Error al cargar el perfil');
      }
    } catch (e) {
      setState(() => cargando = false);
      _mostrarError('Error inesperado: $e');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.setBool('loggedIn', false);
    if (context.mounted) context.go('/login');
  }

  Widget infoItem(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black, // <-- TEXTO LEGIBLE
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black), // <-- TEXTO LEGIBLE
          ),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00AEEF),
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xFF00AEEF),
        foregroundColor: Colors.white,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : perfil == null
              ? const Center(child: Text('No se pudo cargar el perfil', style: TextStyle(color: Colors.white)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.account_circle, size: 100, color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        perfil!.nombreCompleto.toUpperCase(),
                        style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              infoItem('Tipo de Documento', perfil!.tipoDoc),
                              infoItem('Número de Documento', perfil!.numDoc),
                              infoItem('Correo Electrónico', perfil!.email),
                              infoItem('Teléfono Celular', perfil!.celular),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE63946),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text(
                            'Cerrar Sesión',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
    );
  }
}
