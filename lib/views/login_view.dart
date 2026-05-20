import 'welcome_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_view.dart';
import 'sign_in_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool obscure = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> login() async {
    String email = emailController.text.trim().toLowerCase();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _popup("ERROR", "Completa todos los campos.");
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      _popup("BIENVENIDO", "Inicio de sesión exitoso.", success: true);
    } on FirebaseAuthException catch (e) {
      String message = "Error de autenticación.";

      if (e.code == 'user-not-found') {
        message = "Usuario no encontrado.";
      } else if (e.code == 'wrong-password') {
        message = "Contraseña incorrecta.";
      } else if (e.code == 'invalid-email') {
        message = "Correo inválido.";
      } else if (e.code == 'invalid-credential') {
        message = "Credenciales inválidas.";
      }

      _popup("ERROR", message);
    } catch (e) {
      _popup("ERROR", "Ocurrió un error inesperado.");
    }
  }

  void _popup(String title, String msg, {bool success = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(msg, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.pop(context);

              if (success) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeView()),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Center(
          child: Container(
            width: 390,
            height: 844,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Column(
                children: [
                  /// HEADER
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text(
                          "◀ App Store",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HomeView(),
                              ),
                            );
                          },
                          child: const Column(
                            children: [
                              Icon(Icons.home, color: Colors.white, size: 18),
                              Text(
                                "HOME",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.difference,
                    ),
                    child: Image.asset(
                      'assets/images/logo_nada.jpg',
                      width: 140,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "“En NADA lo tienes TODO. Inicia sesión para continuar.”",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "INICIAR SESIÓN / SIGN IN",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  _inputField("E-MAIL", controller: emailController),

                  const SizedBox(height: 15),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: passwordController,
                        obscureText: obscure,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "PASSWORD",
                          hintStyle: const TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 18,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscure ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white54,
                            ),
                            onPressed: () {
                              setState(() {
                                obscure = !obscure;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Text(
                          "INICIAR SESIÓN",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterView()),
                      );
                    },
                    child: const Text(
                      "¿No tienes cuenta? Regístrate",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "¿OLVIDASTE EL PASSWORD? / FORGOT PASSWORD?",
                    style: TextStyle(color: Colors.blue, fontSize: 11),
                  ),

                  const Spacer(),

                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Privacidad y Legales",
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(String hint, {required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 18,
            ),
          ),
        ),
      ),
    );
  }
}
