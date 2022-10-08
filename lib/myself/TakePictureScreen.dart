import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'DisplayPictureScreen.dart';

class TakePictureScreen extends StatefulWidget {
  @override
  State createState() {
    return TakePictureScreenState();
  }
}

class TakePictureScreenState extends State<TakePictureScreen> {
  bool loaded = false;
  late CameraDescription camera;
  late CameraController cameraController;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    availableCameras().then((List<CameraDescription> cameras) {
      camera = cameras.first;
      cameraController = CameraController(camera, ResolutionPreset.medium);
      _initializeControllerFuture = cameraController.initialize();

      setState(() {
        loaded = true;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !loaded
          ? CircularProgressIndicator()
          : FutureBuilder(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(cameraController);
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
      floatingActionButton: Container(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton(
          onPressed: () async {
            await _initializeControllerFuture;
            XFile image = await cameraController.takePicture();
            if (!mounted) return;
            Navigator.push(context, MaterialPageRoute(builder: (context) => DisplayPictureScreen(image.path),));

          },
          child: Icon(Icons.camera_alt),
        ),
      ),
    );
  }
}
