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

  @override
  void dispose() {
    logger.verbose("dispose");
    cameraService.stopImageStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final detectResultFuture =
        cameraService.startImageStream(tfLiteService.classifyImageFromCamera);
    return Scaffold(
      appBar: AppBar(
        title: Text("실시간 마스크 인식"),
      ),
      body: Container(
        width: width,
        child: Stack(
          children: <Widget>[
            CameraPreview(cameraService.camera),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: DetectResultList(detectResultFuture),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
