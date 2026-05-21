import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_view.dart';
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

  /// =========================
  /// CARGAR USUARIO
  /// =========================
  Future<void> loadUserData() async {
    final user = _auth.currentUser;

    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
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
      setState(() {
        userText = user.email ?? "Usuario";
        isLoading = false;
      });
    }
  }

  /// =========================
  /// GUARDAR PERFILES
  /// =========================
  Future<void> saveProfiles() async {
    final user = _auth.currentUser;

    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'profiles': profiles,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error guardando perfiles: $e");
    }
  }

  /// =========================
  /// CERRAR SESIÓN
  /// =========================
  Future<void> logout() async {
    await _auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeView()),
      (route) => false,
    );
  }

  /// =========================
  /// EDITAR PERFIL
  /// =========================
  void editProfile(int index) {
    final controller = TextEditingController(text: profiles[index]["name"]);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],

        title: const Text(
          "Editar Perfil",
          style: TextStyle(color: Colors.white),
        ),

        content: SingleChildScrollView(
          child: Column(
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

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Perfil actualizado")),
              );
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// SELECCIONAR IMAGEN
  /// =========================
  Widget selectImage(int index, String imagePath) {
    return GestureDetector(
      onTap: () {
        setState(() {
          profiles[index]["image"] = imagePath;
        });
      },

      child: CircleAvatar(radius: 32, backgroundImage: AssetImage(imagePath)),
    );
  }

  /// =========================
  /// PERFIL
  /// =========================
  Widget profileCard(int index) {
    return Tooltip(
      message: "Mantén presionada la imagen para editar",
      textStyle: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(10),
      ),

      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CatalogView(profileImage: profiles[index]["image"]),
            ),
          );
        },

        onLongPress: () => editProfile(index),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),

          child: Row(
            children: [
              // =========================
              // FOTO REDONDA
              // =========================
              CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage(profiles[index]["image"]),
              ),

              const SizedBox(width: 20),

              // =========================
              // NOMBRE
              // =========================
              Expanded(
                child: Text(
                  profiles[index]["name"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// =========================
  /// UI
  /// =========================
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
            ),

            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        /// =========================
                        /// LOGO INVERTIDO
                        /// =========================
                        ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.difference,
                          ),
                          child: Image.asset(
                            'assets/images/logo_nada.jpg',
                            width: 150,
                          ),
                        ),

                        const SizedBox(height: 40),

                        const Text(
                          "WELCOME",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          userText,
                          style: const TextStyle(color: Colors.white70),
                        ),

                        const SizedBox(height: 35),

                        const Text(
                          "¿Quién está viendo?",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),

                        const SizedBox(height: 30),

                        Column(
                          children: List.generate(
                            profiles.length,
                            (index) => profileCard(index),
                          ),
                        ),

                        const SizedBox(height: 40),

                        /// =========================
                        /// BOTÓN CERRAR SESIÓN
                        /// =========================
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),

                          child: SizedBox(
                            width: double.infinity,

                            child: ElevatedButton.icon(
                              onPressed: logout,

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),

                              icon: const Icon(Icons.logout),

                              label: const Text(
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
      ),
    );
  }
}
