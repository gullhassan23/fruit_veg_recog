import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fruitrecognition/View/ImageMOdelRecof.dart';

import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    super.dispose();
  }

  // Function to show bottom sheet for image selection
  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: 160,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Select Image From",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Camera Icon
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.camera, size: 40, color: Colors.blue),
                        onPressed: () {
                          _pickImage(ImageSource.camera);
                          Navigator.pop(context);
                        },
                      ),
                      Text("Camera"),
                    ],
                  ),
                  // Gallery Icon
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.photo, size: 40, color: Colors.green),
                        onPressed: () {
                          _pickImage(ImageSource.gallery);
                          Navigator.pop(context);
                        },
                      ),
                      Text("Gallery"),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to pick image
  Future<void> _pickImage(ImageSource source) async {
    XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        profileImage = File(image.path);
      });

      Navigator.push(
        context,
        MaterialPageRoute(
            // builder: (ctx) => Imagesscreen(image: profileImage!),
            builder: (ctx) => Imacreen(image: profileImage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text("Snap your favourite fruit"),
          ),
          SizedBox(height: 40),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              onPressed: _showImagePicker,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.camera), Text(" Open Camera")],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
