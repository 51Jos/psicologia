import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../features/autenticacion/servicios/auth_servicio.dart';

/// Script de ayuda para crear un psicólogo de prueba
///
/// IMPORTANTE: Este archivo es solo para desarrollo/testing
///
/// Para usarlo:
/// 1. Copia este código
/// 2. Pégalo en un Widget temporal en main.dart
/// 3. Ejecuta la app
/// 4. Presiona el botón para crear el psicólogo
///
/// O ejecuta desde terminal:
/// dart run lib/tools/crear_psicologo_prueba.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const CrearPsicologoApp());
}

class CrearPsicologoApp extends StatelessWidget {
  const CrearPsicologoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const CrearPsicologoScreen(),
    );
  }
}

class CrearPsicologoScreen extends StatefulWidget {
  const CrearPsicologoScreen({super.key});

  @override
  State<CrearPsicologoScreen> createState() => _CrearPsicologoScreenState();
}

class _CrearPsicologoScreenState extends State<CrearPsicologoScreen> {
  final _authServicio = AuthServicio();
  final _emailController = TextEditingController(text: 'jperez@ucss.edu.pe');
  final _passwordController = TextEditingController(text: 'temporal123');
  bool _cargando = false;
  String _resultado = '';

  Future<void> _crearPsicologo() async {
    setState(() {
      _cargando = true;
      _resultado = '';
    });

    try {
      final psicologo = await _authServicio.registrarPsicologo(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      setState(() {
        _resultado = '''
✅ ¡Psicólogo creado exitosamente!

📧 Email: ${psicologo.email}
🆔 UID: ${psicologo.id}
📅 Fecha creación: ${psicologo.fechaCreacion}

El psicólogo puede iniciar sesión con:
- Email: ${psicologo.email}
- Password: ${_passwordController.text}

Al iniciar sesión, será redirigido automáticamente
a completar su perfil.
        ''';
      });
    } catch (e) {
      setState(() {
        _resultado = '''
❌ Error al crear psicólogo:

$e

Verifica que:
- El email termine en @ucss.edu.pe
- El email no esté ya registrado
- Firebase esté configurado correctamente
        ''';
      });
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Psicólogo de Prueba'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Crear Psicólogo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'jperez@ucss.edu.pe',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password Temporal',
                hintText: 'temporal123',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _cargando ? null : _crearPsicologo,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
              ),
              child: _cargando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Crear Psicólogo',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 24),
            if (_resultado.isNotEmpty)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _resultado.contains('✅')
                        ? Colors.green[50]
                        : Colors.red[50],
                    border: Border.all(
                      color: _resultado.contains('✅')
                          ? Colors.green
                          : Colors.red,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _resultado,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
