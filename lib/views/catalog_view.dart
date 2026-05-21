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

  // =========================
  // CRUD FIRESTORE
  // =========================
  final CollectionReference moviesRef = FirebaseFirestore.instance.collection(
    'movies',
  );

  final TextEditingController titleController = TextEditingController();
  final TextEditingController genreController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController synopsisController = TextEditingController();

  // CREATE
  Future<void> addMovie() async {
    await moviesRef.add({
      "title": titleController.text,
      "genre": genreController.text,
      "image": imageController.text,
      "synopsis": synopsisController.text,
    });
  }

  // UPDATE
  Future<void> updateMovie(String id) async {
    await moviesRef.doc(id).update({
      "title": titleController.text,
      "genre": genreController.text,
      "image": imageController.text,
      "synopsis": synopsisController.text,
    });
  }

  // DELETE
  Future<void> deleteMovie(String id) async {
    await moviesRef.doc(id).delete();
  }

  void clearControllers() {
    titleController.clear();
    genreController.clear();
    imageController.clear();
    synopsisController.clear();
  }

  // =========================
  // DIALOG CRUD
  // =========================
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

      // =========================
      // BOTÓN CREATE
      // =========================
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () => showMovieDialog(),
        child: const Icon(Icons.add),
      ),

      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: moviesRef.snapshots(),

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.red),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "No hay películas",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final allMovies = snapshot.data!.docs;

            final movies = allMovies.where((movie) {
              final title = movie['title'].toString().toLowerCase();
              return title.contains(searchText.toLowerCase());
            }).toList();

            if (movies.isEmpty) {
              return Column(
                children: [
                  _buildAppBar(),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "No se encontraron películas",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ],
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
                      ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.difference,
                        ),
                        child: Image.asset(
                          'assets/images/logo_nada.jpg',
                          width: 90,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const Spacer(),

                      IconButton(
                        onPressed: () {
                          showSearch(
                            context: context,
                            delegate: MovieSearchDelegate(allMovies: allMovies),
                          );
                        },
                        icon: const Icon(Icons.search, color: Colors.white),
                      ),

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

                            if (!context.mounted) return;

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HomeView(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: "profiles",
                            child: Row(
                              children: [
                                Icon(Icons.switch_account, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  "Cambiar perfil",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: "logout",
                            child: Row(
                              children: [
                                Icon(Icons.logout, color: Colors.red),
                                SizedBox(width: 10),
                                Text(
                                  "Cerrar sesión",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: AssetImage(widget.profileImage),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 550,
                            child: Image.network(
                              movies[0]['image'],
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 550,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.95),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 40,
                            left: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movies[0]['title'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  movies[0]['genre'],
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: 320,
                                  child: Text(
                                    movies[0]['synopsis'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                      ),
                                      onPressed: () {},
                                      icon: const Icon(Icons.play_arrow),
                                      label: const Text("Ver ahora"),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[900],
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => MovieDetailView(
                                              movie:
                                                  movies[0].data()
                                                      as Map<String, dynamic>,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.info_outline),
                                      label: const Text("Información"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "Populares en NADA",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        height: 270,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: movies.length,
                          itemBuilder: (context, index) {
                            final movie = movies[index];

                            return Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MovieDetailView(
                                        movie:
                                            movie.data()
                                                as Map<String, dynamic>,
                                      ),
                                    ),
                                  );
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 170,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        image: DecorationImage(
                                          image: NetworkImage(movie['image']),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),

                                    // 🔥 CRUD botones
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: Column(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                            onPressed: () {
                                              showMovieDialog(
                                                id: movie.id,
                                                data:
                                                    movie.data()
                                                        as Map<String, dynamic>,
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              deleteMovie(movie.id);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(15),
      color: Colors.black,
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.white),
          SizedBox(width: 10),
          Text("Buscar", style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class MovieSearchDelegate extends SearchDelegate {
  final List<QueryDocumentSnapshot> allMovies;

  MovieSearchDelegate({required this.allMovies});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ""),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = allMovies.where((movie) {
      final title = movie['title'].toString().toLowerCase();
      return title.contains(query.toLowerCase());
    }).toList();

    return _buildList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = allMovies.where((movie) {
      final title = movie['title'].toString().toLowerCase();
      return title.contains(query.toLowerCase());
    }).toList();

    return _buildList(results);
  }

  Widget _buildList(List<QueryDocumentSnapshot> movies) {
    return Container(
      color: Colors.black,
      child: ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];

          return ListTile(
            leading: Image.network(movie['image'], width: 50),
            title: Text(
              movie['title'],
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              movie['genre'],
              style: const TextStyle(color: Colors.white70),
            ),
          );
        },
      ),
    );
  }
}
