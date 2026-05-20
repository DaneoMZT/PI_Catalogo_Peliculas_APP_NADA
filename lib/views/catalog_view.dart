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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('movies').snapshots(),

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

            /// FILTRO BUSQUEDA
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
                /// APP BAR
                SliverAppBar(
                  backgroundColor: Colors.black,
                  pinned: true,
                  floating: true,

                  title: Row(
                    children: [
                      /// LOGO
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

                      /// BUSCAR
                      IconButton(
                        onPressed: () {
                          showSearch(
                            context: context,
                            delegate: MovieSearchDelegate(allMovies: allMovies),
                          );
                        },

                        icon: const Icon(Icons.search, color: Colors.white),
                      ),

                      /// PERFIL
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

                /// CONTENIDO
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      /// BANNER
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

                                child: Container(
                                  width: 170,

                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),

                                    image: DecorationImage(
                                      image: NetworkImage(movie['image']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                  child: Align(
                                    alignment: Alignment.bottomCenter,

                                    child: Container(
                                      width: double.infinity,

                                      padding: const EdgeInsets.all(12),

                                      decoration: BoxDecoration(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              bottom: Radius.circular(16),
                                            ),

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

                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,

                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Text(
                                            movie['title'],

                                            maxLines: 2,

                                            overflow: TextOverflow.ellipsis,

                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),

                                          const SizedBox(height: 5),

                                          Text(
                                            movie['genre'],

                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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

/// SEARCH DELEGATE
class MovieSearchDelegate extends SearchDelegate {
  final List<QueryDocumentSnapshot> allMovies;

  MovieSearchDelegate({required this.allMovies});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = "";
        },

        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },

      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = allMovies.where((movie) {
      final title = movie['title'].toString().toLowerCase();

      return title.contains(query.toLowerCase());
    }).toList();

    return _buildMovieList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = allMovies.where((movie) {
      final title = movie['title'].toString().toLowerCase();

      return title.contains(query.toLowerCase());
    }).toList();

    return _buildMovieList(results);
  }

  Widget _buildMovieList(List<QueryDocumentSnapshot> movies) {
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
              movie['genre'],
              style: const TextStyle(color: Colors.white70),
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
          );
        },
      ),
    );
  }
}
