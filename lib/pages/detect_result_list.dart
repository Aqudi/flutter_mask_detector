import 'dart:async';

import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../models/tflite_result.dart';
import '../services/camera_service.dart';
import '../services/logger_service.dart';
import '../services/tflite_service.dart';

class DetectResultList extends StatefulWidget {
  final Future<void> detecResultListFuture;

  const DetectResultList(
    this.detecResultListFuture, {
    Key key,
  }) : super(key: key);

  @override
  _DetectResultListState createState() => _DetectResultListState();
}

class _DetectResultListState extends State<DetectResultList>
    with TickerProviderStateMixin {
  final CameraService cameraService = CameraService();
  final TfLiteService tfliteService = TfLiteService();

  StreamSubscription _streamSubscription;
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

    _streamSubscription = tfliteService.stream.listen((results) {
      if (results == null) return;

      for (final result in _outputs) {
        _animationController
            ?.animateTo(
              result.confidence,
              curve: Curves.bounceIn,
              duration: Duration(milliseconds: 1000),
            )
            ?.orCancel;
      }
      if (mounted) {
        setState(() {
          _outputs = results;
        });
      }
    });
  }

  @override
  void dispose() {
    logger.verbose("dispose");
    _animationController.dispose();
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future: widget.detecResultListFuture,
      builder: (context, snapshot) {
        return Container(
          height: 200.0,
          width: width,
          alignment: Alignment.center,
          color: Colors.white,
          child: (_outputs.isNotEmpty)
              ? _buildResultListView(width)
              : _buildDetectingText(),
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
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) =>
              _buildDetectingResult(width, _outputs[index]),
        );
      },
    );
  }

  _buildDetectingText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Detecting...",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
          ),
        ),
        CircularProgressIndicator(),
      ],
    );
  }

  _buildDetectingResult(width, data) {
    return Column(
      children: [
        Text(
          data.label,
          style: TextStyle(
            color: _colorTween.value,
            fontSize: 20.0,
          ),
        ),
        LinearPercentIndicator(
          width: width * 0.8,
          lineHeight: 14.0,
          percent: data.confidence,
          progressColor: _colorTween.value,
          alignment: MainAxisAlignment.center,
        ),
        Text(
          "${(data.confidence * 100.0).toStringAsFixed(2)} %",
          style: TextStyle(
            color: _colorTween.value,
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }
}
