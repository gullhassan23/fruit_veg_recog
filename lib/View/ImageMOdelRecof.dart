// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class Imacreen extends StatefulWidget {
  final File image;
  Imacreen({Key? key, required this.image}) : super(key: key);

  @override
  State<Imacreen> createState() => _ImacreenState();
}

class _ImacreenState extends State<Imacreen> {
  late Interpreter interpreter;
  List<double>? result;
  List<String> labels = [];

  @override
  void initState() {
    super.initState();
    loadModel();
    loadLabels();
  }

  // Load the TensorFlow Lite model
  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('assets/model_unquant.tflite');
      print("TFLite Model Loaded Successfully");
      runModelOnImage();
    } catch (e) {
      print("Error loading TFLite model: $e");
    }
  }

  // Load labels from assets/labels.txt
  Future<void> loadLabels() async {
    try {
      String labelsData = await rootBundle.loadString('assets/labels.txt');
      labels = labelsData.split('\n').map((e) => e.trim()).toList();
      print("Labels Loaded: $labels");
    } catch (e) {
      print("Error loading labels: $e");
    }
  }

  Future<void> runModelOnImage() async {
    try {
      var imageInput = await processImage(widget.image);

      // Ensure correct shape
      var inputShape = interpreter.getInputTensor(0).shape;
      var outputShape = interpreter.getOutputTensor(0).shape;

      print("Model Expected Input Shape: $inputShape");
      print("Model Output Shape: $outputShape");

      if (imageInput.length != inputShape[0] ||
          imageInput[0].length != inputShape[1] ||
          imageInput[0][0].length != inputShape[2] ||
          imageInput[0][0][0].length != inputShape[3]) {
        print("Error: Image input does not match expected model input shape.");
        return;
      }

      // Define output tensor
      var output = List.filled(outputShape.reduce((a, b) => a * b), 0.0)
          .reshape(outputShape);

      // Run inference
      interpreter.run(imageInput, output);

      print("Model Output: $output");

      setState(() {
        result = List<double>.from(output[0]);
      });
    } catch (e) {
      print("Error running model: $e");
    }
  }

  Future<List<List<List<List<double>>>>> processImage(File imageFile) async {
    final image = img.decodeImage(await imageFile.readAsBytes())!;

    // Resize to 224x224
    final resized = img.copyResize(image, width: 224, height: 224);

    // Convert image to NHWC format (1, 224, 224, 3)
    List<List<List<List<double>>>> input = [
      List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            var pixel = resized.getPixel(x, y);
            return [
              (img.getRed(pixel) / 127.5) - 1, // Normalize to [-1, 1]
              (img.getGreen(pixel) / 127.5) - 1,
              (img.getBlue(pixel) / 127.5) - 1,
            ];
          },
        ),
      )
    ];

    return input;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [imageView(), modelPrediction()],
      ),
    );
  }

  Widget imageView() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Image.file(
          widget.image,
          width: 300,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget modelPrediction() {
    if (result == null) {
      return CircularProgressIndicator();
    }

    // Get the top prediction with the highest confidence
    int predictedIndex =
        result!.indexOf(result!.reduce((a, b) => a > b ? a : b));
    double confidence = result![predictedIndex];

    String predictedLabel =
        (labels.isNotEmpty && predictedIndex < labels.length)
            ? labels[predictedIndex]
            : "Unknown";

    return Column(
      children: [
        Text(
          "Prediction: $predictedLabel",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        Text(
          "Confidence: ${(confidence * 100).toStringAsFixed(2)}%",
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
      ],
    );
  }
}
