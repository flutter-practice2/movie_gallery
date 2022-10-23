import 'package:camera/camera.dart';
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
      try {
        _initializeControllerFuture = cameraController.initialize();
      } catch (e) {
        if (e is CameraException) {
          switch (e.code) {
            case 'CameraAccessDenied':
              print('User denied camera access.');
              break;
            default:
              print('Handle other errors.');
              break;
          }
          Navigator.pop(context);
          return;
        }
        print(e);
      }

      setState(() {
        loaded = true;
      });
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
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
