import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../services/camera_service.dart';
import '../services/logger_service.dart';
import '../services/tflite_service.dart';
import 'detect_result_list.dart';

class RealTimeDetectPage extends StatefulWidget {
  @override
  _RealTimeDetectPageState createState() => _RealTimeDetectPageState();
}

class _RealTimeDetectPageState extends State<RealTimeDetectPage> {
  final CameraService cameraService = CameraService();
  final TfLiteService tfLiteService = TfLiteService();

  Future _getInitFuture() async {
    await tfLiteService.loadModel();
    await cameraService.initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("실시간 마스크 인식"),
      ),
      body: Container(
        width: width,
        child: FutureBuilder<void>(
          future: _getInitFuture(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final detectResultFuture = cameraService
                  .startImageStream(tfLiteService.classifyImageFromCamera);
              return Stack(
                children: <Widget>[
                  CameraPreview(cameraService.camera),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: DetectResultList(detectResultFuture),
                    ),
                  ),
                ],
              );
            } else {
              // Otherwise, display a loading indicator.
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    logger.verbose("dispose");
    cameraService.stopImageStream();
    cameraService.dispose();
    tfLiteService.stopClassifyImageFromCamera();
    super.dispose();
  }
}
