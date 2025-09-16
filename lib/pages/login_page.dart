import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  // Controladores de animación
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  // Controladores del formulario
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final api = ApiService();
  
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scanController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    _scanAnimation =
        Tween<double>(begin: 0, end: 1).animate(_scanController);
  }

  @override
  void dispose() {
    _scanController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF459F38);
    const secondaryColor = Color(0xFFFACC15);
    const accentColor = Colors.white;

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Fondos difuminados circulares
            Positioned(
              top: -150,
              left: -150,
              child: Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              right: -150,
              child: Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Contenido principal
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Escáner de huella animado
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: secondaryColor, width: 4),
                                gradient: RadialGradient(
                                  colors: [
                                    secondaryColor.withOpacity(0.2),
                                    Colors.transparent
                                  ],
                                  radius: 0.8,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.fingerprint,
                              color: secondaryColor,
                              size: 60,
                            ),
                            AnimatedBuilder(
                              animation: _scanAnimation,
                              builder: (context, child) {
                                return Positioned(
                                  top: 120 * _scanAnimation.value - 2,
                                  child: Container(
                                    width: 2,
                                    height: 120,
                                    color: secondaryColor,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Título
                      const Text(
                        "Acceso Seguro",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Inicia sesión para continuar",
                        style: TextStyle(
                          fontSize: 16,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Input DNI/Usuario
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.text,
                        style: const TextStyle(color: accentColor),
                        decoration: InputDecoration(
                          hintText: "DNI",
                          hintStyle: TextStyle(
                            color: accentColor.withOpacity(0.6),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          prefixIcon: Icon(Icons.person,
                              color: accentColor.withOpacity(0.6)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide:
                                const BorderSide(color: secondaryColor, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 2),
                          ),
                          errorStyle: const TextStyle(color: Colors.red),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El N° de documento es requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Input Contraseña
                      TextFormField(
                        controller: passwordController,
                        obscureText: _obscureText,
                        style: const TextStyle(color: accentColor),
                        decoration: InputDecoration(
                          hintText: "Contraseña",
                          hintStyle: TextStyle(
                            color: accentColor.withOpacity(0.6),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          prefixIcon: Icon(Icons.lock,
                              color: accentColor.withOpacity(0.6)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: accentColor.withOpacity(0.6),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide:
                                const BorderSide(color: secondaryColor, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 2),
                          ),
                          errorStyle: const TextStyle(color: Colors.red),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La contraseña es requerida';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Botón de login
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              final email = emailController.text.trim();
                              final password = passwordController.text;
                              
                              try {
                                final success = await api.login(email, password);
                                
                                if (mounted) {
                                  setState(() => _isLoading = false);
                                  
                                  if (success) {
                                    context.go('/');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Credenciales incorrectas'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (mounted) {
                                  setState(() => _isLoading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error de conexión: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          icon: _isLoading 
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF14532D)),
                                  ),
                                )
                              : const Icon(Icons.login, color: Color(0xFF14532D)),
                          label: Text(
                            _isLoading ? "Iniciando..." : "INICIAR SESIÓN",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF14532D),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 6,
                            shadowColor: secondaryColor.withOpacity(0.3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Link de registro
                      GestureDetector(
                        onTap: () => context.go('/register'),
                        child: Text(
                          "¿Eres nuevo? ¡Regístrate!",
                          style: TextStyle(
                            fontSize: 14,
                            color: accentColor.withOpacity(0.8),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "⚠ Esta aplicación es solo para emergencias.",
                  style: TextStyle(
                    fontSize: 12,
                    color: accentColor.withOpacity(0.6),
                  ),
                ),
              ),
            ),

            // Overlay de carga (pantalla completa)
            if (_isLoading)
              Container(
                color: primaryColor.withOpacity(0.8),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(secondaryColor),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Verificando credenciales...',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}