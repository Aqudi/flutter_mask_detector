import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'logger_service.dart';

class CameraService {
  static final _cameraService = CameraService._internal();

  factory CameraService() {
    return _cameraService;
  }

  CameraService._internal();

  CameraController camera;
  final CameraLensDirection _direction = CameraLensDirection.back;

  bool get isInitialized => camera != null && camera.value.isInitialized;
  bool get isStreaming => camera != null && camera.value.isStreamingImages;

  Future<CameraDescription> _getCamera(CameraLensDirection dir) async {
    return await availableCameras().then(
      (cameras) => cameras.firstWhere(
        (camera) => camera.lensDirection == dir,
      ),
    );
  }

  Future<bool> initializeCamera() async {
    if (camera != null || !isInitialized) {
      logger.verbose("Initializing camera..");
      camera = CameraController(
          await _getCamera(_direction),
          defaultTargetPlatform == TargetPlatform.iOS
              ? ResolutionPreset.low
              : ResolutionPreset.high,
          enableAudio: false);
      return camera.initialize().then((value) {
        return isInitialized;
      });
    } else {
      return isInitialized;
    }
  }

  Future<void> startImageStream(Function(CameraImage) onAvailable) async {
    if (!isInitialized) {
      await initializeCamera();
    }
    if (isStreaming) return;

    logger.verbose("Starting ImageStream");
    return camera?.startImageStream((cameraImage) {
      onAvailable(cameraImage);
    });
  }

  Future<void> stopImageStream() async {
    if (isStreaming) {
      await camera.stopImageStream();
    }
  }

  Future<XFile> takePicture() async {
    if (!isInitialized) {
      await initializeCamera();
    }
    logger.verbose("Take a picture");
    return await camera.takePicture();
  }

  void dispose() {
    camera?.dispose();
  }
}
