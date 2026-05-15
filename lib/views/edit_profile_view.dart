import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileView extends StatefulWidget {
  final String currentName;
  final String currentImage;

  const EditProfileView({
    super.key,
    required this.currentName,
    required this.currentImage,
  });

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late TextEditingController nameController;

  File? imageFile;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.currentName);
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Editar Perfil",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          children: [
            const SizedBox(height: 20),

            GestureDetector(
              onTap: pickImage,

              child: Container(
                width: 140,
                height: 140,

                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),

                  image: imageFile != null
                      ? DecorationImage(
                          image: FileImage(imageFile!),
                          fit: BoxFit.cover,
                        )
                      : DecorationImage(
                          image: AssetImage(widget.currentImage),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Toca la imagen para cambiarla",

              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 40),

            TextField(
              controller: nameController,

              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                hintText: "Nombre del perfil",

                hintStyle: const TextStyle(color: Colors.white38),

                filled: true,
                fillColor: Colors.grey[900],

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    "name": nameController.text,
                    "image": imageFile,
                  });
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,

                  padding: const EdgeInsets.all(16),
                ),

                child: const Text(
                  "GUARDAR",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
