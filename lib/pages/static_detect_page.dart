import 'dart:io';

import 'package:flutter/material.dart';

import '../services/image_picker_service.dart';
import '../services/logger_service.dart';
import '../services/tflite_service.dart';
import 'detect_result_list.dart';

class StaticImageClassificationPage extends StatefulWidget {
  @override
  _StaticImageClassificationPageState createState() =>
      _StaticImageClassificationPageState();
}

class _StaticImageClassificationPageState
    extends State<StaticImageClassificationPage> {
  final ImagePickerService imagePickerService = ImagePickerService();
  final TfLiteService tfLiteService = TfLiteService();

  File _image;

  @override
  void dispose() {
    logger.verbose("dispose");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("정적 이미지 마스크 인식"),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.camera_alt),
            onPressed: () async {
              _image = await imagePickerService.getImageFromCamera();
              setState(() {});
            },
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            heroTag: null,
            child: Icon(Icons.image),
            onPressed: () async {
              _image = await imagePickerService.getImageFromGallery();
              setState(() {});
            },
          ),
        ],
      ),
      body: (_image != null)
          ? Column(
              children: [
                Container(
                  height: height * 0.6,
                  child: _buildImage(_image),
                ),
                SizedBox(height: 10),
                DetectResultList(
                  tfLiteService.classifyImageFile(_image),
                ),
              ],
            )
          : Center(
              child: Text("Please take a photo or select a photo."),
            ),
    );
  }

  _buildImage(image) {
    return Image.file(
      image,
      fit: BoxFit.fitHeight,
    );
  }
}
