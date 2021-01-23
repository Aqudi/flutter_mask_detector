import 'dart:async';

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
  final CameraService cameraService = CameraService();
  final TfLiteService tfliteService = TfLiteService();

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
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future:
          cameraService.startImageStream(tfliteService.classifyImageFromCamera),
      builder: (context, snapshot) {
        return Container(
          height: 200.0,
          width: width,
          color: Colors.white,
          child: StreamBuilder(
            stream: tfliteService.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data.isNotEmpty) {
                for (final result in snapshot.data) {
                  _animationController.animateTo(
                    result.confidence,
                    curve: Curves.bounceIn,
                    duration: Duration(milliseconds: 500),
                  );
                }
                _outputs = snapshot.data;
                cameraService.endDetecting();
                return _buildResultListView(width);
              } else {
                return Center(child: _buildWaitingModelText());
              }
            },
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

  @override
  void dispose() {
    logger.verbose("dispose");
    _animationController.dispose();
    cameraService.stopImageStream();
    super.dispose();
  }
}
