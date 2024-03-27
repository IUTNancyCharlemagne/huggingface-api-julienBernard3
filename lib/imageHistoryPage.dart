import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/imagePrediction.dart';

class ImageHistoryPage extends StatelessWidget {
  final List<ImagePrediction> imageHistory;
  final Function(File) setImageURI;

  const ImageHistoryPage({Key? key, required this.imageHistory, required this.setImageURI})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des images'),
      ),
      body: ListView.builder(
        itemCount: imageHistory.length,
        itemBuilder: (context, index) {
          final prediction = imageHistory[index].prediction;
          final imageFile = imageHistory[index].image;

          return ListTile(
            title: Text(prediction),
            leading: Image.file(imageFile, height: 200, fit: BoxFit.cover),
            onTap: () {
              setImageURI(imageFile);
              Navigator.pop(context);
              Navigator.pop(context);
            }
          );
        },
      ),
    );
  }
}
