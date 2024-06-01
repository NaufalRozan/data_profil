import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  final picker = ImagePicker();

  Future<File?> pickGalleryImage() async {
    var imageGallery = await picker.pickImage(source: ImageSource.gallery);
    if (imageGallery != null) {
      return File(imageGallery.path);
    } else {
      return null;
    }
  }

  Future<File?> imageFromCamera() async {
    var imageCamera = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
      maxWidth: 100,
      maxHeight: 100,
    );
    if (imageCamera != null) {
      return File(imageCamera.path);
    } else {
      return null;
    }
  }
}
