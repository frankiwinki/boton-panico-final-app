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

  final direccionCtrl = TextEditingController();

  bool _loading = false;
  final ApiService api = ApiService();

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final data = {
      'num_doc': dniCtrl.text, // ✅ corregido
      'nombres': nombresCtrl.text,
      'tipo_doc': selectedTipoDoc,
      'apellido_paterno': apellidoPaternoCtrl.text,
      'apellido_materno': apellidoMaternoCtrl.text,
      'email': emailCtrl.text,
      'celular': telefonoCtrl.text, // ✅ corregido
      'password': passCtrl.text,
      'password_confirmation':
          passCtrl.text, // ✅ necesario para validación en backend
      'departamento_id': selectedDepartamento,
      'provincia_id': selectedProvincia,
      'distrito_id': selectedDistrito,
      'direccion': direccionCtrl.text,
    };

    final success = await api.registrarUsuario(data);

    if (!mounted) return; // <- ✅ Aquí está la forma correcta

    setState(() => _loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta registrada correctamente')),
      );
      context.go('/login');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error al registrar.')));
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 32),
              Image.asset('assets/images/logo.png', height: 180), // Logo
              const SizedBox(height: 16),
              const Text(
                'Bienvenido',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Abel',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Regístrate para empezar a usar la APP',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontFamily: 'Abel',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
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
                label: 'Departamento',
                value: selectedDepartamento,
                items: departamentos,
                onChanged: (value) {
                  selectedDepartamento = value;
                  _loadProvincias(value!);
                },
              ),
              const SizedBox(height: 16),
              _dropdownField(
                label: 'Provincia',
                value: selectedProvincia,
                items: provincias,
                onChanged: (value) {
                  selectedProvincia = value;
                  _loadDistritos(value!);
                },
              ),
              const SizedBox(height: 16),
              _dropdownField(
                label: 'Distrito',
                value: selectedDistrito,
                items: distritos,
                onChanged: (value) {
                  selectedDistrito = value;
                },
              ),
              const SizedBox(height: 16),
              _customField(direccionCtrl, 'Dirección exacta'),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCB2C1C),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'REGISTRAR',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => context.go('/login'),
                child: const Text(
                  '¿Ya tienes cuenta? Inicia sesión',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

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
