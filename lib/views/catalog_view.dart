import 'movie_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_view.dart';
import 'welcome_view.dart';

class CatalogView extends StatefulWidget {
  final String profileImage;

  const CatalogView({super.key, required this.profileImage});

  @override
  State<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<CatalogView> {
  String searchText = "";

  final CollectionReference moviesRef = FirebaseFirestore.instance.collection(
    'movies',
  );

  final TextEditingController titleController = TextEditingController();
  final TextEditingController genreController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController synopsisController = TextEditingController();

  Future<void> addMovie() async {
    await moviesRef.add({
      "title": titleController.text,
      "genre": genreController.text,
      "image": imageController.text,
      "synopsis": synopsisController.text,
    });
  }

  Future<void> updateMovie(String id) async {
    await moviesRef.doc(id).update({
      "title": titleController.text,
      "genre": genreController.text,
      "image": imageController.text,
      "synopsis": synopsisController.text,
    });
  }

  Future<void> deleteMovie(String id) async {
    await moviesRef.doc(id).delete();
  }

  void clearControllers() {
    titleController.clear();
    genreController.clear();
    imageController.clear();
    synopsisController.clear();
  }

  void showMovieDialog({String? id, Map<String, dynamic>? data}) {
    if (data != null) {
      titleController.text = data['title'];
      genreController.text = data['genre'];
      imageController.text = data['image'];
      synopsisController.text = data['synopsis'];
    } else {
      clearControllers();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          id == null ? "Agregar película" : "Editar película",
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _input(titleController, "Título"),
              _input(genreController, "Género"),
              _input(imageController, "URL Imagen"),
              _input(synopsisController, "Sinopsis"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              clearControllers();
              Navigator.pop(context);
            },
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (id == null) {
                await addMovie();
              } else {
                await updateMovie(id);
              }

              if (!mounted) return; // ✅ FIX

              Navigator.pop(context);
              setState(() {});
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  Widget _input(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () => showMovieDialog(),
        child: const Icon(Icons.add),
      ),

      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: moviesRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.red),
              );
            }

            final allMovies = snapshot.data!.docs;

            final movies = allMovies.where((movie) {
              final title = movie['title'].toString().toLowerCase();
              return title.contains(searchText.toLowerCase());
            }).toList();

            if (movies.isEmpty) {
              return const Center(
                child: Text(
                  "No hay películas",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.black,
                  pinned: true,
                  floating: true,
                  title: Row(
                    children: [
                      const Spacer(),

                      PopupMenuButton<String>(
                        color: Colors.grey[900],
                        onSelected: (value) async {
                          if (value == "profiles") {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WelcomeView(),
                              ),
                            );
                          }

                          if (value == "logout") {
                            await FirebaseAuth.instance.signOut();

                            if (!mounted) return; // ✅ FIX IMPORTANTE

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HomeView(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: "profiles",
                            child: Text("Cambiar perfil"),
                          ),
                          PopupMenuItem(
                            value: "logout",
                            child: Text("Cerrar sesión"),
                          ),
                        ],
                        child: CircleAvatar(
                          backgroundImage: AssetImage(widget.profileImage),
                        ),
                      ),
                    ],
                  ),
                ),

                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final movie = movies[index];

                    return ListTile(
                      leading: Image.network(movie['image'], width: 50),
                      title: Text(movie['title']),
                      subtitle: Text(movie['genre']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MovieDetailView(
                              movie: movie.data() as Map<String, dynamic>,
                            ),
                          ),
                        );
                      },
                    );
                  }, childCount: movies.length),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
