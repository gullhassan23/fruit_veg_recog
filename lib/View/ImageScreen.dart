
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

// ignore: must_be_immutable
class Imagesscreen extends StatefulWidget {
  File image;
  Imagesscreen({
    Key? key,
    required this.image,
  }) : super(key: key);

  @override
  State<Imagesscreen> createState() => _ImagesscreenState();
}

class _ImagesscreenState extends State<Imagesscreen> {
  late ImageLabeler imageLabeler;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final ImageLabelerOptions options =
        ImageLabelerOptions(confidenceThreshold: 0.6);
    imageLabeler = ImageLabeler(options: options);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [imageView(), textFromImage()],
      ),
    );
  }

  Widget imageView() {
    if (widget.image == false) {
      return Center(child: Text("Pick an image for text recognition"));
    }
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40), // Apply border radius
        child: Image.file(
          widget.image,
          width: 300,
          fit: BoxFit.cover, // Ensures the image covers the rounded area
        ),
      ),
    );
  }

  Widget textFromImage() {
    if (widget.image == false) {
      return Center(child: Text("No Result"));
    }
    return FutureBuilder<String?>(
      future: extractText(widget.image),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text("No text found");
        }
        return Text(
          snapshot.data!,
          style: TextStyle(fontSize: 18, color: Colors.black),
        );
      },
    );
  }

  Future<String?> extractText(File file) async {
    try {
      final InputImage inputImage = InputImage.fromFile(file);

      final List<ImageLabel> labels =
          await imageLabeler.processImage(inputImage);

      for (ImageLabel label in labels) {
        final String text = label.label;

        final int index = label.index;
        final double confidence = label.confidence;

        print("title $text with Index is $index and confidence is $confidence");
        return text;
      }
      // final RecognizedText recognizedText =
      //     await textRecognizer.processImage(inputImage);
      // return recognizedText.text;
    } catch (e) {
      print("Error recognizing text: $e");
      return "Error recognizing text";
    }
  }
}
