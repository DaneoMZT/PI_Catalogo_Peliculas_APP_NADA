import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminView extends StatefulWidget {
  final DocumentSnapshot? movieToEdit;

  const AdminView({super.key, this.movieToEdit});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  final CollectionReference movies = FirebaseFirestore.instance.collection(
    'movies',
  );

  final TextEditingController titleController = TextEditingController();
  final TextEditingController genreController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController synopsisController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.movieToEdit != null) {
      final doc = widget.movieToEdit!;
      titleController.text = doc['title'];
      genreController.text = doc['genre'];
      imageController.text = doc['image'];
      synopsisController.text = doc['synopsis'];

      Future.delayed(Duration.zero, () {
        showMovieDialog(doc: doc);
      });
    }
  }

  // =========================
  // ➕ CREATE
  // =========================
  Future<void> addMovie() async {
    await movies.add({
      "title": titleController.text,
      "genre": genreController.text,
      "image": imageController.text,
      "synopsis": synopsisController.text,
    });

    clear();
  }

  // =========================
  // ✏️ UPDATE
  // =========================
  Future<void> updateMovie(String id) async {
    await movies.doc(id).update({
      "title": titleController.text,
      "genre": genreController.text,
      "image": imageController.text,
      "synopsis": synopsisController.text,
    });

    clear();
  }

  // =========================
  // 🗑 DELETE
  // =========================
  Future<void> deleteMovie(String id) async {
    await movies.doc(id).delete();
  }

  void clear() {
    titleController.clear();
    genreController.clear();
    imageController.clear();
    synopsisController.clear();
  }

  // =========================
  // 📦 DIALOG CRUD
  // =========================
  void showMovieDialog({DocumentSnapshot? doc}) {
    if (doc != null) {
      titleController.text = doc['title'];
      genreController.text = doc['genre'];
      imageController.text = doc['image'];
      synopsisController.text = doc['synopsis'];
    } else {
      clear();
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          doc == null ? "Agregar película" : "Editar película",
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: "Título"),
              ),
              TextField(
                controller: genreController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: "Género"),
              ),
              TextField(
                controller: imageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: "URL Imagen"),
              ),
              TextField(
                controller: synopsisController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: "Sinopsis"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (doc == null) {
                await addMovie();
              } else {
                await updateMovie(doc.id);
              }

              if (!mounted) return;
              Navigator.pop(context);
            },
            child: Text(doc == null ? "Agregar" : "Actualizar"),
          ),
        ],
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

      body: StreamBuilder<QuerySnapshot>(
        stream: movies.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final movie = docs[index];

              return Card(
                color: Colors.grey[900],
                child: ListTile(
                  leading: Image.network(movie['image'], width: 50),
                  title: Text(
                    movie['title'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    movie['genre'],
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: PopupMenuButton(
                    color: Colors.black,
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        child: const Text(
                          "Editar",
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Future.delayed(
                            Duration.zero,
                            () => showMovieDialog(doc: movie),
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: const Text(
                          "Eliminar",
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () {
                          deleteMovie(movie.id);
                        },
                      ),
                    ],
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
