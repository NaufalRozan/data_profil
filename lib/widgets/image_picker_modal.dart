import 'package:flutter/cupertino.dart';
import 'package:final_bnsp/widgets/image_picker.dart';
import 'package:flutter/material.dart';

class ImagePickerModal extends StatelessWidget {
  final ImagePickerHelper _imagePickerHelper = ImagePickerHelper();

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: Text('Pilih Sumber Gambar'),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            _imagePickerHelper.pickGalleryImage().then((image) {
              if (image != null) {
                Navigator.pop(context, image);
              }
            });
          },
          child: Text(
            'Photo dari Gallery',
            style: TextStyle(
              color: Colors.blue,
            ),
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            _imagePickerHelper.imageFromCamera().then((image) {
              if (image != null) {
                Navigator.pop(context, image);
              }
            });
          },
          child: Text(
            'Photo dari Camera',
            style: TextStyle(
              color: Colors.blue,
            ),
          ),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text('Batal',
        style: TextStyle(
          color: Colors.red,
        ),),
      ),
    );
  }
}
