import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

import '../models/tflite_result.dart';
import 'logger_service.dart';

class TfLiteService {
  StreamController<List<TfLiteResult>> tfLiteResultsController =
      StreamController.broadcast();

  final _outputs = <TfLiteResult>[];

  bool isBusy = false;
  bool isModelLoaded = false;

  static final TfLiteService _tfliteService = TfLiteService._internal();

  factory TfLiteService() {
    return _tfliteService;
  }

  TfLiteService._internal();

  List<TfLiteResult> get outputs => _outputs;

  Future<String> loadModel() async {
    logger.verbose("loadModel");
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

  void classifyImageFile(File image) async {
    if (isModelLoaded && !isBusy) {
      logger.verbose("classifyImageFile");
      await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
      ).then((results) {
        if (results.isNotEmpty) {
          _updateResult(results);
        }
        isBusy = false;
      }).catchError((e) {
        isModelLoaded = false;
        isBusy = false;
        logger.error(e.toString());
      });
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
        numResults: 5,
      ).then((results) {
        if (results.isNotEmpty) {
          _updateResult(results);
        }
        isBusy = false;
      }).catchError((e) {
        isModelLoaded = false;
        isBusy = false;
        logger.error(e.toString());
      });
    }
  }

  void _updateResult(results) {
    _outputs.clear();
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
    tfLiteResultsController.add(_outputs);
  }

  void disposeModel() {
    Tflite.close();
    tfLiteResultsController.close();
  }
}
