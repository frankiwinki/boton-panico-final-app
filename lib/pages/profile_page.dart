import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService apiService = ApiService();
  UserProfile? perfil;
  bool cargando = true;

  // Paleta de colores combinable
  final Color colorBase = const Color(0xFF459F38);   // Verde base (botones)
  final Color colorOscuro = const Color(0xFF2E6B26); // Verde oscuro (header)
  final Color colorFondo = const Color(0xFFF5F5F5);  // Fondo blanco neutro
  final Color colorTexto = const Color(0xFF4B4B4B);  // Gris oscuro para textos secundarios
  final Color colorError = const Color(0xFFE63946);  // Rojo para errores

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
      SnackBar(
        content: Text(mensaje),
        backgroundColor: colorError,
      ),
    );
  }

  Future<void> _logout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorFondo,
          title: Text('Cerrar Sesión', style: TextStyle(color: colorOscuro)),
          content: Text(
            '¿Estás seguro de que deseas cerrar sesión?',
            style: TextStyle(color: colorTexto),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar', style: TextStyle(color: colorTexto)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: colorBase),
              child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.setBool('loggedIn', false);
      if (context.mounted) context.go('/login');
    }
  }

  void _editarPerfil() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Función de edición en desarrollo'),
        backgroundColor: colorBase,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      body: cargando
          ? Center(
              child: CircularProgressIndicator(color: colorBase),
            )
          : perfil == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: colorOscuro),
                      const SizedBox(height: 16),
                      Text('No se pudo cargar el perfil',
                          style: TextStyle(color: colorTexto, fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarPerfil,
                        style: ElevatedButton.styleFrom(backgroundColor: colorBase),
                        child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header con imagen de perfil
                    Container(
                      decoration: BoxDecoration(
                        color: colorOscuro,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: const [
                                  Spacer(),
                                  Text(
                                    'Perfil',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Spacer(),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 64,
                                    backgroundColor: colorBase,
                                    child: const Icon(Icons.account_circle,
                                        size: 100, color: Colors.white),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    perfil!.nombreCompleto.toUpperCase(),
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Contenido expandible
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            // Header de datos personales
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Datos Personales',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: colorOscuro),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: colorBase.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: _editarPerfil,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 4),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.edit, size: 16, color: colorOscuro),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Editar',
                                                style: TextStyle(
                                                    fontSize: 14, color: colorOscuro),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Tarjeta de datos personales
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white, // tarjeta blanca
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  _buildDataField('Tipo de Documento', perfil!.tipoDoc, showDivider: true),
                                  _buildDataField('Número de Documento', perfil!.numDoc, showDivider: true),
                                  _buildDataField('Correo Electrónico', perfil!.email, showDivider: true),
                                  _buildDataField('Teléfono Celular', perfil!.celular, showDivider: false),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Botón de cerrar sesión
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _logout,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorBase,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.logout, color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Cerrar Sesión',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildDataField(String label, String value, {required bool showDivider}) {
    return Container(
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.3), width: 1),
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colorTexto.withOpacity(0.8))),
                    const SizedBox(height: 4),
                    Text(value,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.black)),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
