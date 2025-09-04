import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;
  String? _tipoEmergencia;
  final TextEditingController _descripcionController = TextEditingController();

  Future<Position> _obtenerUbicacion() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('El servicio de ubicación está deshabilitado');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permiso de ubicación denegado');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Los permisos de ubicación están permanentemente denegados',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _confirmarEnvio() async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF333333), // Fondo oscuro (opcional)
        title: const Text(
          '¿Estás seguro?',
          style: TextStyle(color: Colors.white), // Cambiar color del título
        ),
        content: const Text(
          'Este es un botón de pánico y debe usarse solo en caso de emergencia real. '
          'Activarlo sin necesidad puede generar falsas alarmas y consecuencias innecesarias.\n\n'
          '¿Deseas continuar?',
          style: TextStyle(color: Colors.white), // Cambiar color del contenido
        ),
        actions: [
          TextButton(
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.grey,
              ), // Cambiar color del botón Cancelar
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Sí, confirmar',
              style: TextStyle(
                color: Colors.white,
              ), // Color del texto del botón
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmacion == true) {
      _enviarEmergencia();
    }
  }

  Future<void> _enviarEmergencia() async {
    setState(() => isLoading = true);
    try {
      final posicion = await _obtenerUbicacion();
      final coordenadas = '${posicion.latitude},${posicion.longitude}';

      final api = ApiService();
      final success = await api.enviarEmergencia(
        coordenadas,
        tipo: _tipoEmergencia ?? 'sin especificar',
        descripcion: _descripcionController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Emergencia enviada correctamente'
                : 'Error al enviar la emergencia',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Registra tu emergencia',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Aquí puedes dejar tu Dropdown y TextField como los tenías
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tipo de emergencia:',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _tipoEmergencia,
                dropdownColor: Colors.white,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  hintText: 'Seleccione un tipo',
                ),
                items: const [
                  DropdownMenuItem(value: 'incendio', child: Text('Incendio')),
                  DropdownMenuItem(value: 'robo', child: Text('Robo')),
                  DropdownMenuItem(
                    value: 'accidente',
                    child: Text('Accidente'),
                  ),
                  DropdownMenuItem(value: 'otros', child: Text('Otros')),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipoEmergencia = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Descripción:',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descripcionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Describe brevemente la situación',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              const SizedBox(height: 16),
              GestureDetector(
                onTap: isLoading ? null : _confirmarEnvio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/boton_panico.png', // Asegúrate de que esta imagen exista en assets
                      width: 200,
                      height: 200,
                    ),
                    if (isLoading)
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
