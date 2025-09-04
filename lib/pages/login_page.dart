import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _isLoading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final api = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00AEEF), // Fondo celeste
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Image.asset('assets/images/logo.png', height: 160),
                    ),
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        'Bienvenido',
                        style: TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontFamily: 'Abel',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Inicia sesión para continuar',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontFamily: 'Abel',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Email
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontFamily: 'Abel'),
                      decoration: InputDecoration(
                        hintText: 'Correo electrónico',
                        filled: true,
                        fillColor: Colors.white,
                        hintStyle: const TextStyle(fontFamily: 'Abel'),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El correo es requerido';
                        }
                        final emailRegex = RegExp(
                            r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                        if (!emailRegex.hasMatch(value)) {
                          return 'Ingrese un correo válido';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Contraseña
                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscureText,
                      style: const TextStyle(fontFamily: 'Abel'),
                      decoration: InputDecoration(
                        hintText: 'Contraseña',
                        filled: true,
                        fillColor: Colors.white,
                        hintStyle: const TextStyle(fontFamily: 'Abel'),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey[700],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La contraseña es requerida';
                        }
                        return null;
                      },
                    ),

                    // const SizedBox(height: 8),

                    // Align(
                    //   alignment: Alignment.centerRight,
                    //   child: TextButton(
                    //     onPressed: () => context.go('/forgot'),
                    //     child: const Text(
                    //       '¿Olvidaste tu Contraseña?',
                    //       style: TextStyle(
                    //         color: Colors.white70,
                    //         fontFamily: 'Abel',
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    const SizedBox(height: 24),

                    // Botón Iniciar sesión
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);
                            final email = emailController.text.trim();
                            final password = passwordController.text;
                            final success = await api.login(email, password);
                            setState(() => _isLoading = false);

                            if (success) {
                              context.go('/');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Credenciales incorrectas'),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCB2C1C), // Rojo fuerte
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'INICIAR SESIÓN',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Abel',
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ¿Nuevo usuario?
                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/register'),
                        child: const Text(
                          '¿Eres nuevo? ¡Regístrate!',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Abel',
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Indicador de carga
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
