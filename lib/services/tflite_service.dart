import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

import '../models/tflite_result.dart';
import 'logger_service.dart';

class TfLiteService {
  StreamController<List<TfLiteResult>> _streamController =
      StreamController.broadcast();

  bool isBusy = false;
  bool isModelLoaded = false;

  static final TfLiteService _tfliteService = TfLiteService._internal();

  factory TfLiteService() {
    return _tfliteService;
  }

  TfLiteService._internal();

  Stream<List<TfLiteResult>> get stream => _streamController.stream;

  Future<String> loadModel() async {
    logger.verbose("loadModel");
    _streamController.add(null);
    return Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
    ).then((value) {
      logger.verbose("loadModel $value");
      isModelLoaded = true;
      return value;
    }).catchError((e) {
      logger.error("loadModel $e");
      isModelLoaded = false;
    });
  }

  Future<void> classifyImageFile(File image) async {
    if (isModelLoaded && !isBusy) {
      logger.verbose("classifyImageFile");
      isBusy = true;
      await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
      ).then((results) {
        if (results.isNotEmpty) {
          _updateResult(results);
        }
      }).catchError((e) {
        isModelLoaded = false;
        logger.error(e.toString());
      });
      isBusy = false;
    }
  }

  void classifyImageFromCamera(CameraImage image) async {
    if (isModelLoaded && !isBusy) {
      logger.verbose("classifyImageFromCamera");
      isBusy = true;
      await Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        numResults: 2,
      ).then((results) {
        if (results.isNotEmpty) {
          _updateResult(results);
        }
      }).catchError((e) {
        isModelLoaded = false;
        logger.error(e.toString());
      });
      isBusy = false;
    }
  }

  void stopClassifyImageFromCamera() async {
    if (!_streamController.isClosed) {
      _streamController.add(null);
      _streamController.close();
    }
  }

  void _updateResult(results) {
    if (results.isNotEmpty) {
      final _outputs = <TfLiteResult>[];
      for (final result in results) {
        _outputs.add(
          TfLiteResult(
            id: result['index'],
            confidence: result['confidence'],
            label: result['label'],
          ),
        );
        var msg = "index:  ${result['index']}\n";
        msg += "confidence: ${result['confidence']}\n";
        msg += "label: ${result['label']}";
        logger.verbose(msg);
      }
      _outputs.sort((a, b) => a.confidence.compareTo(b.confidence));

      if (_streamController.isClosed) {
        logger.verbose("Init streamcontroller");
        _streamController = StreamController.broadcast();
        _streamController.add(null);
      }
      _streamController.add(_outputs);
    }
  }

  void dispose() {
    _streamController.close();
  }
}
