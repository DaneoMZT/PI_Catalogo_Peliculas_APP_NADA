import 'package:firebase_auth/firebase_auth.dart';
import 'home_view.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'catalog_view.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String userText = "Cargando...";
  bool isLoading = true;

  List<Map<String, dynamic>> profiles = [
    {"name": "Daniel", "image": "assets/images/profile1.jpg"},

    {"name": "Kids", "image": "assets/images/profile2.jpg"},

    {"name": "Invitado", "image": "assets/images/profile3.jpg"},

    {"name": "Anime", "image": "assets/images/profile4.jpg"},
  ];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  String fixImagePath(String path) {
    return path.replaceAll("assets/assets/", "assets/");
  }

  Future<void> saveProfiles() async {
    try {
      final user = _auth.currentUser;

      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'profiles': profiles,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error guardando perfiles: $e");
    }
  }

  Future<void> loadUserData() async {
    try {
      final user = _auth.currentUser;

      if (user == null) return;

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data();

        setState(() {
          userText = data?['email'] ?? user.email ?? "Usuario";

          if (data?['profiles'] != null) {
            profiles = List<Map<String, dynamic>>.from(data!['profiles']);
          }

          isLoading = false;
        });
      } else {
        setState(() {
          userText = user.email ?? "Usuario";
          isLoading = false;
        });
      }
    } catch (e) {
      final user = _auth.currentUser;

      setState(() {
        userText = user?.email ?? "Usuario";
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    await _auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeView()),
      (route) => false,
    );
  }

  void editProfile(int index) {
    final TextEditingController controller = TextEditingController(
      text: profiles[index]["name"],
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],

        title: const Text(
          "Editar Perfil",
          style: TextStyle(color: Colors.white),
        ),

        content: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            TextField(
              controller: controller,

              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                hintText: "Nuevo nombre",

                hintStyle: const TextStyle(color: Colors.white54),

                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade700),
                ),

                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Selecciona una imagen",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 15),

            Wrap(
              spacing: 10,
              runSpacing: 10,

              children: [
                selectImage(index, "assets/images/profile1.jpg"),

                selectImage(index, "assets/images/profile2.jpg"),

                selectImage(index, "assets/images/profile3.jpg"),

                selectImage(index, "assets/images/profile4.jpg"),
              ],
            ),
          ],
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },

            child: const Text("Cancelar"),
          ),

          ElevatedButton(
            onPressed: () async {
              setState(() {
                profiles[index]["name"] = controller.text.trim().isEmpty
                    ? profiles[index]["name"]
                    : controller.text.trim();
              });

              await saveProfiles();

              if (!mounted) return;

              Navigator.pop(context);
            },

            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  Widget selectImage(int index, String imagePath) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          profiles[index]["image"] = imagePath;
        });

        await saveProfiles();
      },

      child: Container(
        width: 60,
        height: 60,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),

          border: Border.all(color: Colors.white24),

          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget profileCard(int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CatalogView(profileImage: profiles[index]["image"]),
          ),
        );
      },
      onLongPress: () {
        editProfile(index);
      },

      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),

              image: DecorationImage(
                image: AssetImage(fixImagePath(profiles[index]["image"])),

                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            profiles[index]["name"],

            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
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
                  color: Colors.black.withValues(alpha: 0.7),

                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),

            child: isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        CircularProgressIndicator(color: Colors.white),

                        SizedBox(height: 20),

                        Text(
                          "Cargando perfiles...",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      const SizedBox(height: 40),

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

                      const SizedBox(height: 40),

                      const Text(
                        "WELCOME",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        userText,

                        textAlign: TextAlign.center,

                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "¿Quién está viendo?",

                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),

                      const SizedBox(height: 50),

                      Wrap(
                        spacing: 30,
                        runSpacing: 30,
                        alignment: WrapAlignment.center,

                        children: List.generate(
                          profiles.length,
                          (index) => profileCard(index),
                        ),
                      ),

                      const Spacer(),

                      const Text(
                        "Mantén presionado un perfil para editar",

                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),

                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),

                        child: SizedBox(
                          width: double.infinity,

                          child: ElevatedButton(
                            onPressed: logout,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,

                              foregroundColor: Colors.black,

                              padding: const EdgeInsets.all(16),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),

                            child: const Text(
                              "CERRAR SESIÓN",

                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
