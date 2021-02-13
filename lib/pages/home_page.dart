import 'package:flutter/material.dart';

import '../services/camera_service.dart';
import '../services/logger_service.dart';
import '../services/tflite_service.dart';
import 'realtime_detec_page.dart';
import 'static_detect_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CameraService cameraService = CameraService();
  final TfLiteService tfLiteService = TfLiteService();

  Future _getInitFuture() async {
    await tfLiteService.loadModel();
    await cameraService.initializeCamera();
  }

  @override
  void dispose() {
    logger.verbose("dispose");
    cameraService.stopImageStream();
    cameraService.dispose();
    tfLiteService.stopClassifyImageFromCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TfLite example"),
      ),
      body: FutureBuilder<void>(
        future: _getInitFuture(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RaisedButton(
                    child: Text("실시간 영상"),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RealTimeDetectPage(),
                      ),
                    ),
                  ),
                  RaisedButton(
                    child: Text("이미지 선택"),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StaticImageClassificationPage(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
