import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/profileManagement/cubits/uploadProfileCubit.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/customDialog.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:image_picker/image_picker.dart';

class ChooseProfileDialog extends StatefulWidget {
  final String id;
  final UploadProfileCubit bloc;
  ChooseProfileDialog({required this.id, required this.bloc});
  @override
  _ChooseProfileDialog createState() => _ChooseProfileDialog();
}

class _ChooseProfileDialog extends State<ChooseProfileDialog> {
  File? image;
  // get image File camera
  _getFromCamera(BuildContext context) async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    File rotatedImage =
        await FlutterExifRotation.rotateAndSaveImage(path: pickedFile!.path);

    image = rotatedImage;
    //File(pickedFile.path);
    final userId = widget.id;
    widget.bloc.uploadProfilePicture(image, userId);
  }

//get image file from library
  _getFromGallery(BuildContext context) async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    File rotatedImage =
        await FlutterExifRotation.rotateAndSaveImage(path: pickedFile!.path);

    image = rotatedImage;
    //File(pickedFile.path);
    final userId = widget.id;
    widget.bloc.uploadProfilePicture(image, userId);
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
        showbackButton: true,
        height: MediaQuery.of(context).size.height * .2,
        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)), //this right here
        child: Container(
            decoration: BoxDecoration(
                color: Constants.white,
                borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton.icon(
                        icon: Icon(
                          Icons.photo_library,
                          color: Constants.primaryColor,
                        ),
                        label: Text(
                          AppLocalization.of(context)!
                              .getTranslatedValues("photoLibraryLbl")!,
                          style: TextStyle(
                              color: Constants.black1,
                              fontWeight: FontWeight.w500),
                        ),
                        onPressed: () {
                          _getFromGallery(context);
                          Navigator.of(context).pop();
                        }),
                    TextButton.icon(
                      icon: Icon(
                        Icons.photo_camera,
                        color: Constants.primaryColor,
                      ),
                      label: Text(
                        AppLocalization.of(context)!
                            .getTranslatedValues("cameraLbl")!,
                        style: TextStyle(
                            color: Constants.black1,
                            fontWeight: FontWeight.w500),
                      ),
                      onPressed: () {
                        _getFromCamera(context);
                        Navigator.of(context).pop();
                      },
                    )
                  ]),
            )));
  }
}
