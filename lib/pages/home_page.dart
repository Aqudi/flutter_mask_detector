import 'package:flutter/material.dart';

import 'realtime_detec_page.dart';
import 'static_detect_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TfLite example"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RaisedButton(
              child: Text("실시간 영상"),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RealTimeDetectPage()),
              ),
            ),
            RaisedButton(
              child: Text("이미지 선택"),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => StaticImageClassificationPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
