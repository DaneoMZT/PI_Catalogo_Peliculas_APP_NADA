import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_view.dart';
import 'login_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  bool obscure = true;
  bool loading = false;

  final TextEditingController aliasController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔥 REGISTRO FIREBASE
  Future<void> registerUser() async {
    String alias = aliasController.text.trim().toLowerCase();
    String email = emailController.text.trim().toLowerCase();
    String password = passwordController.text.trim();

    if (alias.isEmpty || email.isEmpty || password.isEmpty) {
      _popup("ERROR", "Completa todos los campos.");
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final aliasQuery = await _firestore
          .collection('users')
          .where('alias', isEqualTo: alias)
          .limit(1)
          .get();

      if (aliasQuery.docs.isNotEmpty) {
        setState(() {
          loading = false;
        });

        _popup("ALIAS NO DISPONIBLE", "Ese alias ya existe.");
        return;
      }

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = credential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        "uid": uid,
        "alias": alias,
        "email": email,
        "createdAt": FieldValue.serverTimestamp(),
      });

      setState(() {
        loading = false;
      });

      _popup("CUENTA CREADA", "Bienvenido @$alias", success: true);
    } on FirebaseAuthException catch (e) {
      setState(() {
        loading = false;
      });

      String message = "Error de autenticación.";

      if (e.code == 'email-already-in-use') {
        message = "El correo ya está registrado.";
      } else if (e.code == 'weak-password') {
        message = "La contraseña es demasiado débil.";
      } else if (e.code == 'invalid-email') {
        message = "Correo inválido.";
      }

      _popup("ERROR", message);
    } catch (e) {
      setState(() {
        loading = false;
      });

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
                  MaterialPageRoute(builder: (_) => const HomeView()),
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
                          "◀ Inicio",
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
                      "“En NADA lo tienes TODO. Regístrate y comienza a ver sin límites.”",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "CREAR CUENTA",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  _inputField("ALIAS", controller: aliasController),

                  const SizedBox(height: 15),

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
                        onPressed: loading ? null : registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.all(16),
                        ),
                        child: loading
                            ? const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              )
                            : const Text(
                                "CREAR CUENTA",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "¿Ya tienes cuenta?",
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginView(),
                            ),
                          );
                        },
                        child: const Text(
                          "INICIAR SESIÓN",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
