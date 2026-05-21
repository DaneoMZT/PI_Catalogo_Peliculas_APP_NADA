import 'movie_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
  // FIRESTORE
  // =========================
  final CollectionReference moviesRef = FirebaseFirestore.instance.collection(
    'movies',
  );

  // =========================
  // CONTROLLERS
  // =========================
  final TextEditingController titleController = TextEditingController();

  final TextEditingController genreController = TextEditingController();

  final TextEditingController yearController = TextEditingController();

  final TextEditingController imageController = TextEditingController();

  final TextEditingController synopsisController = TextEditingController();

  // =========================
  // CREATE
  // =========================
  Future<void> addMovie() async {
    await moviesRef.add({
      "title": titleController.text.trim(),
      "genre": genreController.text.trim(),
      "year": yearController.text.trim(),
      "image": imageController.text.trim(),
      "synopsis": synopsisController.text.trim(),
    });
  }

  // =========================
  // UPDATE
  // =========================
  Future<void> updateMovie(String id) async {
    await moviesRef.doc(id).update({
      "title": titleController.text.trim(),
      "genre": genreController.text.trim(),
      "year": yearController.text.trim(),
      "image": imageController.text.trim(),
      "synopsis": synopsisController.text.trim(),
    });
  }

  // =========================
  // DELETE
  // =========================
  Future<void> deleteMovie(String id) async {
    await moviesRef.doc(id).delete();
  }

  // =========================
  // CLEAR INPUTS
  // =========================
  void clearControllers() {
    titleController.clear();
    genreController.clear();
    yearController.clear();
    imageController.clear();
    synopsisController.clear();
  }

  // =========================
  // DIALOG CRUD
  // =========================
  void showMovieDialog({String? id, Map<String, dynamic>? data}) {
    if (data != null) {
      titleController.text = data['title']?.toString() ?? '';
      genreController.text = data['genre']?.toString() ?? '';
      yearController.text = data['year']?.toString() ?? '';
      imageController.text = data['image']?.toString() ?? '';
      synopsisController.text = data['synopsis']?.toString() ?? '';
    } else {
      clearControllers();
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],

        title: Text(
          id == null ? "Agregar película" : "Editar película",
          style: const TextStyle(color: Colors.white),
        ),

        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _input(titleController, "Título"),
              _input(genreController, "Género"),
              _input(yearController, "Año"),
              _input(imageController, "URL Imagen"),
              _input(synopsisController, "Sinopsis"),
            ],
          ),
        ),

        actions: [
          TextButton(
            onPressed: () {
              clearControllers();
              Navigator.pop(dialogContext);
            },
            child: const Text("Cancelar"),
          ),

          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);

              if (id == null) {
                await addMovie();
              } else {
                await updateMovie(id);
              }

              if (!mounted) return;

              navigator.pop();

              setState(() {});
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  // =========================
  // INPUT
  // =========================
  Widget _input(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,

        style: const TextStyle(color: Colors.white),

        decoration: InputDecoration(
          labelText: label,

          labelStyle: const TextStyle(color: Colors.white70),

          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade700),
          ),

          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // =========================
      // BOTÓN AGREGAR
      // =========================
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          showMovieDialog();
        },
        child: const Icon(Icons.add),
      ),

      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: moviesRef.snapshots(),

          builder: (context, snapshot) {
            // =========================
            // LOADING
            // =========================
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.red),
              );
            }

            // =========================
            // EMPTY
            // =========================
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

            return CustomScrollView(
              slivers: [
                // =========================
                // APPBAR
                // =========================
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

                      // =========================
                      // SEARCH
                      // =========================
                      IconButton(
                        onPressed: () {
                          showSearch(
                            context: context,
                            delegate: MovieSearchDelegate(allMovies: allMovies),
                          );
                        },

                        icon: const Icon(Icons.search, color: Colors.white),
                      ),

                      // =========================
                      // PROFILE MENU
                      // =========================
                      PopupMenuButton<String>(
                        color: Colors.grey[900],

                        onSelected: (value) async {
                          // =========================
                          // CHANGE PROFILE
                          // =========================
                          if (value == "profiles") {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WelcomeView(),
                              ),
                            );
                          }

                          // =========================
                          // LOGOUT
                          // =========================
                          if (value == "logout") {
                            final navigator = Navigator.of(context);

                            await FirebaseAuth.instance.signOut();

                            if (!mounted) return;

                            navigator.pushAndRemoveUntil(
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

                // =========================
                // CONTENT
                // =========================
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // =========================
                      // BANNER
                      // =========================
                      CarouselSlider.builder(
                        itemCount: movies.length,

                        options: CarouselOptions(
                          height: 550,
                          viewportFraction: 1,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 4),
                        ),

                        itemBuilder: (context, index, realIndex) {
                          final movie = movies[index];

                          return Stack(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 550,

                                child: Image.network(
                                  movie['image'],
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

                                child: SizedBox(
                                  width: 350,

                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        movie['title'],

                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 38,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      Text(
                                        "${movie['genre']} • ${movie['year']}",

                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      Text(
                                        movie['synopsis'],

                                        maxLines: 4,

                                        overflow: TextOverflow.ellipsis,

                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
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

                      // =========================
                      // HORIZONTAL LIST
                      // =========================
                      SizedBox(
                        height: 270,

                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,

                          itemCount: movies.length,

                          itemBuilder: (context, index) {
                            final movie = movies[index];

                            return Padding(
                              padding: const EdgeInsets.only(left: 15),

                              child: Stack(
                                children: [
                                  // =========================
                                  // MOVIE CARD
                                  // =========================
                                  InkWell(
                                    borderRadius: BorderRadius.circular(16),

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

                                    child: Container(
                                      width: 170,

                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),

                                        image: DecorationImage(
                                          image: NetworkImage(movie['image']),

                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // =========================
                                  // MENU
                                  // =========================
                                  Positioned(
                                    top: 5,
                                    right: 5,

                                    child: PopupMenuButton<String>(
                                      color: Colors.grey[900],

                                      position: PopupMenuPosition.under,

                                      onSelected: (value) async {
                                        // EDIT
                                        if (value == "edit") {
                                          showMovieDialog(
                                            id: movie.id,

                                            data:
                                                movie.data()
                                                    as Map<String, dynamic>,
                                          );
                                        }

                                        // DELETE
                                        if (value == "delete") {
                                          final confirm = await showDialog<bool>(
                                            context: context,

                                            builder: (_) => AlertDialog(
                                              backgroundColor: Colors.grey[900],

                                              title: const Text(
                                                "Eliminar película",

                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),

                                              content: const Text(
                                                "¿Deseas eliminar esta película?",

                                                style: TextStyle(
                                                  color: Colors.white70,
                                                ),
                                              ),

                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      context,
                                                      false,
                                                    );
                                                  },

                                                  child: const Text("Cancelar"),
                                                ),

                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),

                                                  onPressed: () {
                                                    Navigator.pop(
                                                      context,
                                                      true,
                                                    );
                                                  },

                                                  child: const Text("Eliminar"),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            await deleteMovie(movie.id);
                                          }
                                        }
                                      },

                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: "edit",

                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.edit,
                                                color: Colors.blue,
                                              ),

                                              SizedBox(width: 10),

                                              Text(
                                                "Editar",

                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const PopupMenuItem(
                                          value: "delete",

                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),

                                              SizedBox(width: 10),

                                              Text(
                                                "Eliminar",

                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],

                                      child: Container(
                                        padding: const EdgeInsets.all(6),

                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.7,
                                          ),

                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),

                                        child: const Icon(
                                          Icons.more_vert,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
}

// =========================
// SEARCH
// =========================
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
            leading: Image.network(
              movie['image'],
              width: 50,
              fit: BoxFit.cover,
            ),

            title: Text(
              movie['title'],

              style: const TextStyle(color: Colors.white),
            ),

            subtitle: Text(
              "${movie['genre']} • ${movie['year']}",

              style: const TextStyle(color: Colors.white70),
            ),
          );
        },
      ),
    );
  }
}
