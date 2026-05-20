import 'package:flutter/material.dart';
//import 'catalog_view.dart';
//import 'upload_movies.dart';

import '../widgets/custom_button.dart';
import 'login_view.dart';
import 'sign_in_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,

      body: Center(
        child: Container(
          width: 390,
          height: 844,

          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(40),
          ),

          child: SafeArea(
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
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {},

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

                const Spacer(),

                ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.difference,
                  ),

                  child: Image.asset('assets/images/logo_nada.jpg', width: 180),
                ),

                const Spacer(),

                /// TEXTO
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),

                  child: Text(
                    "“En NADA lo tienes TODO. Regístrate y comienza a ver sin límites.”",

                    textAlign: TextAlign.center,

                    style: TextStyle(color: Colors.white),
                  ),
                ),

                const Spacer(),

                /// BOTÓN LOGIN
                CustomButton(
                  text: "INICIAR SESIÓN",

                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginView()),
                      //MaterialPageRoute(builder: (_) => const UploadMovies()),
                    );
                  },
                ),

                CustomButton(
                  text: "REGÍSTRATE",

                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterView()),
                    );
                  },
                ),

                const SizedBox(height: 20),

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
    );
  }
}
