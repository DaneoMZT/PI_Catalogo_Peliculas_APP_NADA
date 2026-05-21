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

  Future<void> addMovie() async {
    await moviesRef.add({
      "title": titleController.text.trim(),
      "genre": genreController.text.trim(),
      "year": yearController.text.trim(),
      "image": imageController.text.trim(),
      "synopsis": synopsisController.text.trim(),
    });
  }

  Future<void> updateMovie(String id) async {
    await moviesRef.doc(id).update({
      "title": titleController.text.trim(),
      "genre": genreController.text.trim(),
      "year": yearController.text.trim(),
      "image": imageController.text.trim(),
      "synopsis": synopsisController.text.trim(),
    });
  }

  Future<void> deleteMovie(String id) async {
    await moviesRef.doc(id).delete();
  }

  void clearControllers() {
    titleController.clear();
    genreController.clear();
    yearController.clear();
    imageController.clear();
    synopsisController.clear();
  }

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          id == null ? "Agregar película" : "Editar Película",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width:
              320, // Ajustado para mantenerse armónico dentro del contenedor base
          child: SingleChildScrollView(
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
        ),
        actions: [
          TextButton(
            onPressed: () {
              clearControllers();
              Navigator.pop(dialogContext);
            },
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final dialogNavigator = Navigator.of(dialogContext);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              if (id == null) {
                await addMovie();
              } else {
                await updateMovie(id);
              }

              if (!mounted) return;

              dialogNavigator.pop();

              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(
                    id == null ? "Película agregada" : "Perfil actualizado",
                  ),
                ),
              );

              setState(() {});
            },
            child: const Text(
              "Guardar",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.black26,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade800),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white70),
          ),
        ),
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
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: StreamBuilder<QuerySnapshot>(
                stream: moviesRef.snapshots(),
                builder: (context, snapshot) {
                  // Loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  // Empty
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Scaffold(
                      backgroundColor: Colors.black,
                      appBar: AppBar(
                        backgroundColor: Colors.black,
                        elevation: 0,
                        actions: [
                          IconButton(
                            onPressed: () => showMovieDialog(),
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                      body: const Center(
                        child: Text(
                          "No hay películas",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
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
                      // AppBar principal rediseñada dentro del contenedor
                      SliverAppBar(
                        backgroundColor: Colors.black,
                        primary: false,
                        pinned: true,
                        floating: true,
                        elevation: 0,
                        title: Padding(
                          padding: const EdgeInsets.only(
                            top: 16,
                            left: 4,
                            right: 4,
                          ),
                          child: Row(
                            children: [
                              ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.difference,
                                ),
                                child: Image.asset(
                                  'assets/images/logo_nada.jpg',
                                  width: 120,
                                  height: 40,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const Spacer(),

                              // Search
                              IconButton(
                                onPressed: () {
                                  showSearch(
                                    context: context,
                                    delegate: MovieSearchDelegate(
                                      allMovies: allMovies,
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.search,
                                  color: Colors.white,
                                ),
                              ),

                              // Agregar Película
                              IconButton(
                                onPressed: () {
                                  showMovieDialog();
                                },
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 4),

                              // Profile Menu
                              PopupMenuButton<String>(
                                color: Colors.grey[900],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
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
                                        Icon(
                                          Icons.switch_account,
                                          color: Colors.white,
                                        ),
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
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundImage: AssetImage(
                                    widget.profileImage,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Listado de Contenido
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),

                            // Carousel Slider con Esquinas Completamente Redondeadas
                            CarouselSlider.builder(
                              itemCount: movies.length,
                              options: CarouselOptions(
                                height:
                                    430, // Reducido ligeramente para un ajuste óptimo en el contenedor vertical
                                viewportFraction: 0.88,
                                enlargeCenterPage: true,
                                autoPlay: true,
                                autoPlayInterval: const Duration(seconds: 5),
                              ),
                              itemBuilder: (context, index, realIndex) {
                                final movie = movies[index];

                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.6,
                                        ),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      30,
                                    ), // Fuerza el redondeado en la imagen de red
                                    child: Stack(
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          height: double.infinity,
                                          child: Image.network(
                                            movie['image'],
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                                      color: Colors.grey[800],
                                                      child: const Icon(
                                                        Icons.broken_image,
                                                        color: Colors.white38,
                                                        size: 40,
                                                      ),
                                                    ),
                                          ),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withValues(
                                                  alpha: 0.95,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 24,
                                          left: 20,
                                          right: 20,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                movie['title'],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                "${movie['genre']}  •  ${movie['year']}",
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                movie['synopsis'],
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white60,
                                                  fontSize: 12,
                                                  height: 1.3,
                                                ),
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

                            const SizedBox(height: 25),

                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 25),
                              child: Text(
                                "Populares en NADA",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Lista Horizontal Redondeada
                            SizedBox(
                              height: 220,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: movies.length,
                                itemBuilder: (context, index) {
                                  final movie = movies[index];
                                  final movieData =
                                      movie.data() as Map<String, dynamic>;

                                  return Padding(
                                    padding: EdgeInsets.only(
                                      left: 25,
                                      right: index == movies.length - 1
                                          ? 25
                                          : 0,
                                    ),
                                    child: Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => MovieDetailView(
                                                  movie: movieData,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 140,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.4),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(
                                                22,
                                              ), // Esquinas redondeadas para las portadas inferiores
                                              child: Image.network(
                                                movie['image'],
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => Container(
                                                      color: Colors.grey[800],
                                                      child: const Icon(
                                                        Icons.broken_image,
                                                        color: Colors.white30,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Acciones CRUD flotantes sobre la tarjeta
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: PopupMenuButton<String>(
                                            color: Colors.grey[900],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            position: PopupMenuPosition.under,
                                            onSelected: (value) async {
                                              if (value == "edit") {
                                                showMovieDialog(
                                                  id: movie.id,
                                                  data: movieData,
                                                );
                                              }

                                              if (value == "delete") {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (_) => AlertDialog(
                                                    backgroundColor:
                                                        Colors.grey[900],
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            22,
                                                          ),
                                                    ),
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
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              false,
                                                            ),
                                                        child: const Text(
                                                          "Cancelar",
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        style:
                                                            ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Colors.red,
                                                            ),
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              true,
                                                            ),
                                                        child: const Text(
                                                          "Eliminar",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
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
                                                  alpha: 0.6,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.more_vert,
                                                color: Colors.white,
                                                size: 18,
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
          ),
        ),
      ),
    );
  }
}

class MovieSearchDelegate extends SearchDelegate {
  final List<QueryDocumentSnapshot> allMovies;

  MovieSearchDelegate({required this.allMovies});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      scaffoldBackgroundColor: Colors.black,
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white54),
        border: InputBorder.none,
      ),
      appBarTheme: AppBarTheme(backgroundColor: Colors.grey[900], elevation: 0),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: Colors.white),
        onPressed: () => query = "",
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = allMovies.where((movie) {
      final title = movie['title'].toString().toLowerCase();
      return title.contains(query.toLowerCase());
    }).toList();

    return _buildList(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = allMovies.where((movie) {
      final title = movie['title'].toString().toLowerCase();
      return title.contains(query.toLowerCase());
    }).toList();

    return _buildList(context, results);
  }

  Widget _buildList(BuildContext context, List<QueryDocumentSnapshot> movies) {
    return Container(
      color: Colors.black,
      child: ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    movie['image'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.white30,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  movie['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "${movie['genre']} • ${movie['year']}",
                  style: const TextStyle(color: Colors.white54),
                ),
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
              ),
            ),
          );
        },
      ),
    );
  }
}
