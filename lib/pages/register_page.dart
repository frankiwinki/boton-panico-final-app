import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final dniCtrl = TextEditingController();
  final nombresCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final apellidoPaternoCtrl = TextEditingController();
  final apellidoMaternoCtrl = TextEditingController();
  final direccionCtrl = TextEditingController();

  List<Map<String, dynamic>> departamentos = [];
  List<Map<String, dynamic>> provincias = [];
  List<Map<String, dynamic>> distritos = [];

  final List<Map<String, String>> tiposDoc = [
    {'value': 'DNI', 'label': 'DNI'},
    {'value': 'CE', 'label': 'Carné de Extranjería'},
    {'value': 'PAS', 'label': 'Pasaporte'},
  ];

  String? selectedTipoDoc = 'DNI'; // Valor por defecto
  String? selectedDepartamento;
  String? selectedProvincia;
  String? selectedDistrito;

  bool _loading = false;
  final ApiService api = ApiService();

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final data = {
      'num_doc': dniCtrl.text,
      'nombres': nombresCtrl.text,
      'tipo_doc': selectedTipoDoc,
      'apellido_paterno': apellidoPaternoCtrl.text,
      'apellido_materno': apellidoMaternoCtrl.text,
      'email': emailCtrl.text,
      'celular': telefonoCtrl.text,
      'password': passCtrl.text,
      'password_confirmation': passCtrl.text,
      'departamento_id': selectedDepartamento,
      'provincia_id': selectedProvincia,
      'distrito_id': selectedDistrito,
      'direccion': direccionCtrl.text,
    };

    final success = await api.registrarUsuario(data);

    if (!mounted) return;

    setState(() => _loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta registrada correctamente')),
      );
      context.go('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDepartamentos();
  }

  Future<void> _loadDepartamentos() async {
    departamentos = await api.getDepartamentos();
    setState(() {});
  }

  Future<void> _loadProvincias(String depId) async {
    provincias = await api.getProvincias(depId);
    distritos = [];
    selectedProvincia = null;
    selectedDistrito = null;
    setState(() {});
  }

  Future<void> _loadDistritos(String provId) async {
    distritos = await api.getDistritos(provId);
    selectedDistrito = null;
    setState(() {});
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // Fondo degradado
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF013237), // Verde más claro 
                Color(0xFF4CA771), // Verde turquesa 
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // Contenido
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: MediaQuery.of(context).size.width * 0.70,
                    height: MediaQuery.of(context).size.height * 0.35,
                    fit: BoxFit.contain,
                  ),
                ),
                
                // TODO EL CONTENIDO CON MARGEN NEGATIVO MUY AGRESIVO
                Transform.translate(
                  offset: const Offset(0, -80), // Subir TODO mucho más
                  child: Column(
                    children: [
                      // Texto de bienvenida
                      const Text(
                        'Bienvenido',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Abel',
                        ),
                      ),
                      const SizedBox(height: 2), 
                      const Text(
                        'Regístrate para empezar a usar la APP',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontFamily: 'Abel',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8), // Formulario cerca del texto

                      // Aquí tus campos y formulario ↓↓↓
                      _dropdownTipoDocField(
                        label: 'Tipo de documento',
                        value: selectedTipoDoc,
                        items: tiposDoc,
                        onChanged: (value) {
                          setState(() => selectedTipoDoc = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      _customField(dniCtrl, 'N° Documento'),
                      const SizedBox(height: 16),
                      _customField(nombresCtrl, 'Nombres'),
                      const SizedBox(height: 16),
                      _customField(apellidoPaternoCtrl, 'Apellido paterno'),
                      const SizedBox(height: 16),
                      _customField(apellidoMaternoCtrl, 'Apellido materno'),
                      const SizedBox(height: 16),
                      _customField(emailCtrl, 'Correo electrónico'),
                      const SizedBox(height: 16),
                      _customField(telefonoCtrl, 'Celular'),
                      const SizedBox(height: 16),
                      _customField(passCtrl, 'Contraseña', obscure: true),
                      const SizedBox(height: 16),
                      _dropdownField(
                        label: 'Distrito',
                        value: selectedDistrito,
                        items: distritos,
                        onChanged: (value) {
                          setState(() => selectedDistrito = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      _customField(direccionCtrl, 'Dirección exacta'),
                      const SizedBox(height: 32),

                      // Botón
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE76268),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'REGISTRAR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Abel',
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: const Text(
                          '¿Ya tienes cuenta? Inicia sesión',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Abel',
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}



  // Campos personalizados
  Widget _customField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Campo requerido' : null,
    );
  }

  Widget _dropdownField({
    required String label,
    required String? value,
    required List<Map<String, dynamic>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item['id'].toString(),
              child: Text(item['nombre']),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Campo requerido' : null,
    );
  }

  Widget _dropdownTipoDocField({
    required String label,
    required String? value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item['value'],
              child: Text(item['label']!),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Campo requerido' : null,
    );
  }
}