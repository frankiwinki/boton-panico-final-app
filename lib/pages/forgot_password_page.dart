import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;

  void _recover() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    // Simulación de recuperación
    await Future.delayed(const Duration(seconds: 1));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correo enviado con instrucciones')),
      );
      context.pop();
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
                validator: (value) => value != null && value.contains('@')
                    ? null
                    : 'Correo inválido',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _recover,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Enviar instrucciones'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
