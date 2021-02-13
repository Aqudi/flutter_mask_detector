# flutter_mask_detector

[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://pub.dev/packages/effective_dart)

코로나 종식을 위한 올바른 마스크 착용 권장앱

## 개발

- lefthook 설치 & lefthook install
  1. [링크](https://github.com/Arkweid/lefthook)
  2. ```shell
     lefthook install
     ```

## 사용법

1. 오픈소스로 공개된 또는 직접 훈련시킨 식별 모델을 준비한다.
2. tflite로 변환을 한다.
3. tflite 모델과 labels.txt를 assets에 저장한다.

## 삽질

1. setState() called after dispose()

   - 아래와 같이 mounted된 상태일때만 호출하도록 해야한다.

   ```dart
   if(mounted) {
     setState({})
   }
   ```

2. Bad state: Stream has already been listened to.
   - broadcast 타입의 스트림을 사용해야한다.
   ```
   StreamController<> controller = StreamController.broadcast();
   ```
