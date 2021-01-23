import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../services/camera_service.dart';
import '../services/logger_service.dart';
import 'realtime_detect_list.dart';

class RealTimeDetectPage extends StatefulWidget {
  @override
  _RealTimeDetectPageState createState() => _RealTimeDetectPageState();
}

class _RealTimeDetectPageState extends State<RealTimeDetectPage>
    with TickerProviderStateMixin {
  CameraService cameraService = CameraService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("실시간 마스크 인식"),
      ),
      body: FutureBuilder<void>(
        future: cameraService.initializeCamera(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Column(
              children: <Widget>[
                CameraPreview(cameraService.camera),
                RealTimeDetectReslutList(),
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
    super.dispose();
  }
}
