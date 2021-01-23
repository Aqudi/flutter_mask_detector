import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  static final ImagePickerService _imagePickerService =
      ImagePickerService._internal();

  final ImagePicker imagePicker;

  factory ImagePickerService() {
    return _imagePickerService;
  }

  ImagePickerService._internal() : imagePicker = ImagePicker();

  Future<File> getImageFromGallery() async {
    final imageSource = ImageSource.gallery;
    final image = await imagePicker.getImage(source: imageSource);
    final imageFile = File(image.path);
    return imageFile;
  }

  Future<File> getImageFromCamera() async {
    final imageSource = ImageSource.camera;
    final image = await imagePicker.getImage(source: imageSource);
    final imageFile = File(image.path);
    return imageFile;
  }
}
