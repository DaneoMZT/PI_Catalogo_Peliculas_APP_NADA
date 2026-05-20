import 'package:flutter/material.dart';

class MovieDetailView extends StatelessWidget {
  final Map<String, dynamic> movie;

  const MovieDetailView({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            /// IMAGEN
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 500,

                  child: Image.network(movie['image'], fit: BoxFit.cover),
                ),

                Container(
                  width: double.infinity,
                  height: 500,

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
                  top: 50,
                  left: 15,

                  child: CircleAvatar(
                    backgroundColor: Colors.black54,

                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  /// TITULO
                  Text(
                    movie['title'],

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// AÑO
                  infoItem("Año", movie['year'].toString()),

                  /// DIRECTOR
                  infoItem("Director", movie['director']),

                  /// GÉNERO
                  infoItem("Género", movie['genre']),

                  const SizedBox(height: 25),

                  const Text(
                    "Sinopsis",

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    movie['synopsis'],

                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),

                      onPressed: () {},

                      icon: const Icon(Icons.play_arrow),

                      label: const Text(
                        "VER AHORA",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            "$title: ",

            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          Expanded(
            child: Text(
              value,

              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
