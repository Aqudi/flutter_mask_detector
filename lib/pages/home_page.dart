import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/tflite_result.dart';
import '../pages/detecting_result.dart';
import '../services/camera_service.dart';
import '../services/logger_service.dart';
import '../services/tflite_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  CameraService cameraService = CameraService();
  TfLiteService tfliteService = TfLiteService();

  AnimationController _animationController;
  Animation _colorTween;

  List<TfLiteResult> _outputs = [];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _colorTween = ColorTween(
      begin: Colors.green,
      end: Colors.red,
    ).animate(_animationController);

    tfliteService.loadModel();
    tfliteService.tfLiteResultsController.stream.listen(
      (results) {
        for (final result in results) {
          _animationController.animateTo(
            result.confidence,
            curve: Curves.bounceIn,
            duration: Duration(milliseconds: 500),
          );
        }
        setState(() {
          _outputs = results;
          cameraService.isDetecting = false;
        });
      },
      onDone: () {},
      onError: logger.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TfLite example"),
      ),
      body: FutureBuilder<void>(
        future: cameraService
            .startImageStream(tfliteService.classifyImageFromCamera),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Stack(
              children: <Widget>[
                CameraPreview(cameraService.camera),
                DetectResult(
                  colorTween: _colorTween,
                  animationController: _animationController,
                  outputs: _outputs,
                ),
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    logger.verbose("dispose");
    cameraService.stopImageStream();
    tfliteService.disposeModel();
    super.dispose();
  }
}
