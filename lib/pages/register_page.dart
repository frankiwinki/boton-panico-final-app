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

  String? selectedTipoDoc = 'DNI';
  String? selectedDepartamento;
  String? selectedProvincia;
  String? selectedDistrito;
  bool _obscureText = true;

  bool _loading = false;
  final ApiService api = ApiService();

  // Colores basados en el diseño HTML
  static const Color primaryColor = Color(0xFF459F38);
  static const Color backgroundColor = Color(0xFFF0FDF4);
  static const Color inputBgColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF152013);
  static const Color placeholderColor = Color(0xFF6B7280);
  static const Color accentColor = Color(0xFF37B027);

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
        const SnackBar(
          content: Text('Cuenta registrada correctamente'),
          backgroundColor: primaryColor,
        ),
      );
      context.go('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al registrar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDistritos();
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

  Future<void> _loadDistritos() async {
    distritos = await api.getDistritos("0219");
    selectedDistrito = null;
    setState(() {});
  }

  Future<void> _consultarDni() async {
    final dni = dniCtrl.text.trim();
    if (dni.isEmpty) return;

    final result = await api.consultarDni(dni);

    if (result.isNotEmpty && result['success'] == true) {
      final data = result['data'];
      nombresCtrl.text = data["nombres"];
      apellidoPaternoCtrl.text = data["apellido_paterno"];
      apellidoMaternoCtrl.text = data["apellido_materno"];
    }

    setState(() {});
  }

  @override
  void dispose() {
    dniCtrl.dispose();
    nombresCtrl.dispose();
    emailCtrl.dispose();
    telefonoCtrl.dispose();
    passCtrl.dispose();
    apellidoPaternoCtrl.dispose();
    apellidoMaternoCtrl.dispose();
    direccionCtrl.dispose();
    super.dispose();
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    VoidCallback? onBlur,
  }) {
    final focusNode = FocusNode();
    
    if (onBlur != null) {
      focusNode.addListener(() {
        if (!focusNode.hasFocus) {
          onBlur();
        }
      });
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(
          fontSize: 18,
          color: textColor,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: placeholderColor,
            fontSize: 18,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: placeholderColor,
              size: 24,
            ),
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: inputBgColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 56,
            vertical: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFE5E7EB),
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFE5E7EB),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: primaryColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<Map<String, dynamic>> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        style: const TextStyle(
          fontSize: 18,
          color: textColor,
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(
            color: placeholderColor,
            fontSize: 18,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: placeholderColor,
              size: 24,
            ),
          ),
          filled: true,
          fillColor: inputBgColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 56,
            vertical: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFE5E7EB),
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFE5E7EB),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: primaryColor,
              width: 2,
            ),
          ),
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
        validator: validator,
      ),
    );
  }

  Widget _buildTipoDocDropdown({
    required String label,
    required String? value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        style: const TextStyle(
          fontSize: 18,
          color: textColor,
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(
            color: placeholderColor,
            fontSize: 18,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: placeholderColor,
              size: 24,
            ),
          ),
          filled: true,
          fillColor: inputBgColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 56,
            vertical: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFE5E7EB),
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFE5E7EB),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: primaryColor,
              width: 2,
            ),
          ),
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
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Fondo verde curvado en la parte superior
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(64),
                bottomRight: Radius.circular(64),
              ),
            ),
          ),

          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Crear Cuenta',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                // Formulario en contenedor blanco curvado
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 32),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(48),
                        topRight: Radius.circular(48),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Formulario
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  const SizedBox(height: 24),

                                  // Tipo de documento
                                  _buildTipoDocDropdown(
                                    label: 'Tipo de documento',
                                    value: selectedTipoDoc,
                                    items: tiposDoc,
                                    icon: Icons.assignment_outlined,
                                    onChanged: (value) {
                                      setState(() => selectedTipoDoc = value);
                                    },
                                    validator: (value) => value == null ? 'Campo requerido' : null,
                                  ),
                                  const SizedBox(height: 24),

                                  // Número de documento
                                  _buildInputField(
                                    controller: dniCtrl,
                                    hintText: 'N° Documento',
                                    icon: Icons.badge_outlined,
                                    keyboardType: TextInputType.number,
                                    onBlur: _consultarDni,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'El número de documento es requerido';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Nombres
                                  _buildInputField(
                                    controller: nombresCtrl,
                                    hintText: 'Nombres',
                                    icon: Icons.person,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Los nombres son requeridos';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Apellido paterno
                                  _buildInputField(
                                    controller: apellidoPaternoCtrl,
                                    hintText: 'Apellido paterno',
                                    icon: Icons.person_outline,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'El apellido paterno es requerido';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Apellido materno
                                  _buildInputField(
                                    controller: apellidoMaternoCtrl,
                                    hintText: 'Apellido materno',
                                    icon: Icons.person_outline,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'El apellido materno es requerido';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Email (opcional)
                                  _buildInputField(
                                    controller: emailCtrl,
                                    hintText: 'Correo electrónico (opcional)',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 24),

                                  // Teléfono
                                  _buildInputField(
                                    controller: telefonoCtrl,
                                    hintText: 'Celular',
                                    icon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'El celular es requerido';
                                      }
                                      if (value.trim().length < 9) {
                                        return 'El celular debe tener al menos 9 dígitos';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Contraseña
                                  _buildInputField(
                                    controller: passCtrl,
                                    hintText: 'Contraseña',
                                    icon: Icons.lock_outline,
                                    obscureText: _obscureText,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: placeholderColor,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'La contraseña es requerida';
                                      }
                                      if (value.length < 6) {
                                        return 'La contraseña debe tener al menos 6 caracteres';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Distrito
                                  _buildDropdownField(
                                    label: 'Distrito',
                                    value: selectedDistrito,
                                    items: distritos,
                                    icon: Icons.location_city,
                                    onChanged: (value) {
                                      setState(() => selectedDistrito = value);
                                    },
                                    validator: (value) => value == null ? 'Campo requerido' : null,
                                  ),
                                  const SizedBox(height: 24),

                                  // Dirección
                                  _buildInputField(
                                    controller: direccionCtrl,
                                    hintText: 'Dirección exacta',
                                    icon: Icons.home_outlined,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'La dirección es requerida';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 32),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Footer con botón
                        Container(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              // Botón de registro
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 64,
                                  child: ElevatedButton(
                                    onPressed: _loading ? null : _register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                    child: _loading
                                        ? const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Registrando...',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          )
                                        : const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'REGISTRAR',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(
                                                Icons.arrow_forward,
                                                size: 24,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Link para iniciar sesión
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    '¿Ya tienes una cuenta? ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.go('/login'),
                                    child: const Text(
                                      'Inicia Sesión',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}