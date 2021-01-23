import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../models/tflite_result.dart';

class DetectResult extends StatelessWidget {
  const DetectResult({
    Key key,
    @required Animation colorTween,
    @required AnimationController animationController,
    @required this.outputs,
  })  : _colorTween = colorTween,
        _animationController = animationController,
        super(key: key);

  final Animation _colorTween;
  final AnimationController _animationController;
  final List<TfLiteResult> outputs;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 200.0,
          width: width,
          color: Colors.white,
          child: outputs != null && outputs.isNotEmpty
              ? ListView.builder(
                  itemCount: outputs.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(20.0),
                  itemBuilder: (context, index) {
                    return Column(
                      children: <Widget>[
                        Text(
                          outputs[index].label,
                          style: TextStyle(
                            color: _colorTween.value,
                            fontSize: 20.0,
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) => LinearPercentIndicator(
                            width: width * 0.88,
                            lineHeight: 14.0,
                            percent: outputs[index].confidence,
                            progressColor: _colorTween.value,
                          ),
                        ),
                        _buildConfidenceText(outputs[index].confidence),
                      ],
                    );
                  })
              : _buildWaitingModelText(),
        ),
      ),
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
