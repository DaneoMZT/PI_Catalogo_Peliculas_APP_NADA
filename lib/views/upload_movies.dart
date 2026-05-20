import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadMovies extends StatefulWidget {
  const UploadMovies({super.key});

  @override
  State<UploadMovies> createState() => _UploadMoviesState();
}

class _UploadMoviesState extends State<UploadMovies> {
  final List<Map<String, dynamic>> movies = [
    {
      "title": "Batman",
      "year": "2022",
      "director": "Matt Reeves",
      "genre": "Acción",
      "synopsis": "Batman investiga asesinatos en Gotham.",
      "image":
          "https://upload.wikimedia.org/wikipedia/en/8/87/Batman_%282022_film%29_poster.jpg",
    },

    {
      "title": "Interstellar",
      "year": "2014",
      "director": "Christopher Nolan",
      "genre": "Ciencia ficción",
      "synopsis": "Viaje espacial para salvar a la humanidad.",
      "image":
          "https://upload.wikimedia.org/wikipedia/en/b/bc/Interstellar_film_poster.jpg",
    },

    {
      "title": "Joker",
      "year": "2019",
      "director": "Todd Phillips",
      "genre": "Drama",
      "synopsis": "Origen del villano Joker.",
      "image":
          "https://upload.wikimedia.org/wikipedia/en/e/e1/Joker_%282019_film%29_poster.jpg",
    },

    {
      "title": "Avengers Endgame",
      "year": "2019",
      "director": "Russo Brothers",
      "genre": "Acción",
      "synopsis": "Los Avengers enfrentan a Thanos.",
      "image":
          "https://upload.wikimedia.org/wikipedia/en/0/0d/Avengers_Endgame_poster.jpg",
    },
    {
      "title": "Demon Slayer: Castillo Infinito Parte 1",
      "year": "2025",
      "director": "Haruo Sotozaki",
      "genre": "Anime",
      "category": "Anime",
      "synopsis":
          "Tanjiro Kamado y los Hashira ingresan al misterioso Castillo Infinito para enfrentar la batalla definitiva contra Muzan Kibutsuji y las lunas superiores demoníacas.",
      "image":
          "https://upload.wikimedia.org/wikipedia/en/4/4b/Demon_Slayer_Kimetsu_no_Yaiba_logo.svg",
    },

    {
      "title": "Dragon Ball Super: La Resurrección de Freezer",
      "year": "2015",
      "director": "Tadayoshi Yamamuro",
      "genre": "Anime",
      "category": "Anime",
      "synopsis":
          "Después de años en el infierno, Freezer es revivido con un solo objetivo: vengarse de Goku y destruir a los guerreros Z con una nueva transformación aterradora.",
      "image":
          "https://upload.wikimedia.org/wikipedia/en/7/74/Dragon_Ball_Z_Resurrection_%27F%27_poster.jpg",
    },

    {
      "title": "The Matrix",
      "year": "1999",
      "director": "Wachowski Sisters",
      "genre": "Ciencia ficción",
      "category": "Películas",
      "synopsis":
          "Neo descubre que el mundo en el que vive es una simulación creada por máquinas y se convierte en la última esperanza para liberar a la humanidad.",
      "image":
          "https://upload.wikimedia.org/wikipedia/en/c/c1/The_Matrix_Poster.jpg",
    },

    {
      "title": "The Matrix Reloaded",
      "year": "2003",
      "director": "Wachowski Sisters",
      "genre": "Ciencia ficción",
      "category": "Películas",
      "synopsis":
          "Mientras Zion se prepara para una guerra total contra las máquinas, Neo busca respuestas sobre su destino dentro de Matrix.",
      "image":
          "https://upload.wikimedia.org/wikipedia/en/b/ba/Poster_-_The_Matrix_Reloaded.jpg",
    },

    {
      "title": "The Matrix Revolutions",
      "year": "2003",
      "director": "Wachowski Sisters",
      "genre": "Ciencia ficción",
      "category": "Películas",
      "synopsis":
          "La batalla final entre humanos y máquinas comienza mientras Neo enfrenta al agente Smith para decidir el futuro de ambas realidades.",
      "image":
          "https://upload.wikimedia.org/wikipedia/en/3/34/Matrix_revolutions_ver7.jpg",
    },

    {
      "title": "The Matrix Resurrections",
      "year": "2021",
      "director": "Lana Wachowski",
      "genre": "Ciencia ficción",
      "category": "Películas",
      "synopsis":
          "Neo vuelve a cuestionar su realidad cuando extraños recuerdos y nuevas amenazas lo obligan a regresar nuevamente a Matrix.",
      "image":
          "https://upload.wikimedia.org/wikipedia/en/5/50/The_Matrix_Resurrections.jpg",
    },

    {
      "title": "Transformers",
      "year": "2007",
      "director": "Michael Bay",
      "genre": "Acción",
      "category": "Películas",
      "synopsis":
          "Autobots y Decepticons llegan a la Tierra en busca de un poderoso artefacto capaz de decidir el destino del universo.",
      "image":
          "https://upload.wikimedia.org/wikipedia/en/6/66/Transformers07.jpg",
    },

    {
      "title": "Transformers Revenge of the Fallen",
      "year": "2009",
      "director": "Michael Bay",
      "genre": "Acción",
      "category": "Películas",
      "synopsis":
          "Optimus Prime y los Autobots enfrentan el regreso de los Decepticons mientras una antigua amenaza busca destruir el Sol.",
      "image":
          "https://upload.wikimedia.org/wikipedia/en/8/8e/Transformers_2_poster.jpg",
    },

    {
      "title": "Transformers Dark of the Moon",
      "year": "2011",
      "director": "Michael Bay",
      "genre": "Acción",
      "category": "Películas",
      "synopsis":
          "Un secreto oculto en la Luna desencadena una nueva guerra entre Autobots y Decepticons que pone en riesgo a toda la humanidad.",
      "image":
          "https://upload.wikimedia.org/wikipedia/en/7/7f/Transformers_dark_of_the_moon_ver5.jpg",
    },

    {
      "title": "Transformers Age of Extinction",
      "year": "2014",
      "director": "Michael Bay",
      "genre": "Acción",
      "category": "Películas",
      "synopsis":
          "Con los Transformers perseguidos por los humanos, Optimus Prime descubre una amenaza capaz de destruir la Tierra y el universo.",
      "image":
          "https://upload.wikimedia.org/wikipedia/en/0/0f/Transformers_Age_of_Extinction_poster.jpg",
    },

    {
      "title": "Chainsaw Man: Arco de Reze",
      "year": "2025",
      "director": "MAPPA",
      "genre": "Anime",
      "category": "Anime",
      "synopsis":
          "Denji conoce a Reze, una misteriosa chica que cambiará su vida mientras una peligrosa conspiración demoníaca comienza a desarrollarse.",
      "image": "https://upload.wikimedia.org/wikipedia/en/2/24/Chainsawman.jpg",
    },

    {
      "title": "Attack on Titan",
      "year": "2013",
      "director": "Tetsuro Araki",
      "genre": "Anime",
      "category": "Anime",
      "synopsis":
          "La humanidad vive encerrada tras enormes murallas para sobrevivir al ataque constante de gigantes devoradores conocidos como titanes.",
      "image":
          "https://upload.wikimedia.org/wikipedia/en/7/70/Attack_on_Titan_S1_DVD.jpg",
    },

    {
      "title": "Iron Man",
      "year": "2008",
      "director": "Jon Favreau",
      "genre": "Acción",
      "category": "Marvel",
      "synopsis":
          "Tras ser secuestrado, Tony Stark crea una armadura avanzada para escapar y convertirse en el poderoso héroe Iron Man.",
      "image":
          "https://upload.wikimedia.org/wikipedia/en/7/70/Ironmanposter.JPG",
    },

    {
      "title": "Iron Man 2",
      "year": "2010",
      "director": "Jon Favreau",
      "genre": "Acción",
      "category": "Marvel",
      "synopsis":
          "Tony Stark enfrenta nuevas amenazas mientras el gobierno y peligrosos enemigos intentan apoderarse de su tecnología.",
      "image":
          "https://upload.wikimedia.org/wikipedia/en/e/ed/Iron_Man_2_poster.jpg",
    },

    {
      "title": "Iron Man 3",
      "year": "2013",
      "director": "Shane Black",
      "genre": "Acción",
      "category": "Marvel",
      "synopsis":
          "Después de los eventos de Avengers, Tony Stark enfrenta al Mandarín mientras lucha contra sus propios miedos y traumas.",
      "image":
          "https://upload.wikimedia.org/wikipedia/en/d/d5/Iron_Man_3_theatrical_poster.jpg",
    },

    {
      "title": "The Big Bang Theory",
      "year": "2007",
      "director": "Chuck Lorre",
      "genre": "Comedia",
      "category": "Series",
      "synopsis":
          "Un grupo de brillantes científicos intenta sobrevivir a los desafíos de la vida cotidiana, el amor y la amistad con situaciones hilarantes.",
      "image":
          "https://upload.wikimedia.org/wikipedia/en/7/7a/The_Big_Bang_Theory_season_12.jpg",
    },

    {
      "title": "Jurassic Park",
      "year": "1993",
      "director": "Steven Spielberg",
      "genre": "Ciencia ficción",
      "category": "Películas",
      "synopsis":
          "Un parque temático con dinosaurios clonados se convierte en una pesadilla cuando las criaturas escapan de control.",
      "image":
          "https://upload.wikimedia.org/wikipedia/en/e/e7/Jurassic_Park_poster.jpg",
    },
  ];

  Future<void> uploadMovies() async {
    final firestore = FirebaseFirestore.instance;

    for (var movie in movies) {
      await firestore.collection('movies').add(movie);
    }
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Películas subidas correctamente")),
    );
  }

  @override
  void initState() {
    super.initState();

    uploadMovies();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,

      body: Center(child: CircularProgressIndicator(color: Colors.red)),
    );
  }
}
