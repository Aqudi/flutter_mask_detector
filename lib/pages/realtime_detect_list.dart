import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../models/tflite_result.dart';
import '../services/camera_service.dart';
import '../services/logger_service.dart';
import '../services/tflite_service.dart';

class RealTimeDetectReslutList extends StatefulWidget {
  @override
  _RealTimeDetectReslutListState createState() =>
      _RealTimeDetectReslutListState();
}

class _RealTimeDetectReslutListState extends State<RealTimeDetectReslutList>
    with TickerProviderStateMixin {
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
    final width = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future:
          cameraService.startImageStream(tfliteService.classifyImageFromCamera),
      builder: (context, snapshot) {
        return Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 200.0,
              width: width,
              color: Colors.white,
              child: _outputs != null && _outputs.isNotEmpty
                  ? _buildResultListView(width)
                  : _buildWaitingModelText(),
            ),
          ),
        );
      },
    );
  }

  _buildResultListView(width) {
    return ListView.builder(
      itemCount: _outputs.length,
      shrinkWrap: true,
      padding: const EdgeInsets.all(20.0),
      itemBuilder: (context, index) {
        return Column(
          children: <Widget>[
            Text(
              _outputs[index].label,
              style: TextStyle(
                color: _colorTween.value,
                fontSize: 20.0,
              ),
            ),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) => LinearPercentIndicator(
                width: width * 0.8,
                lineHeight: 14.0,
                percent: _outputs[index].confidence,
                progressColor: _colorTween.value,
                alignment: MainAxisAlignment.center,
              ),
            ),
            _buildConfidenceText(_outputs[index].confidence),
          ],
        );
      },
    );
  }

  _buildWaitingModelText() {
    return Center(
      child: Text(
        "Wating for model to detect..",
        style: TextStyle(
          color: Colors.black,
          fontSize: 20.0,
        ),
      ),
    );
  }

  _buildConfidenceText(confidence) {
    return Text(
      "${(confidence * 100.0).toStringAsFixed(2)} %",
      style: TextStyle(
        color: _colorTween.value,
        fontSize: 16.0,
      ),
    );
  }
}
