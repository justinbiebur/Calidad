

import 'dart:io';

import 'package:calidad/provider/user_provider.dart';
import 'package:calidad/utils/call_methods.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class Otoscope extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserProvider user = Provider.of<UserProvider>(context);
    String uid = user.getUser.uid;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Otoscope"),
      ),
      body: Container(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
            Container(
              child: ElevatedButton(
                onPressed: (){
                  uploadToStorage(user.getUser.uid);
                },
                child: Icon(Icons.upload_outlined),
              ),
            ),
            Container(
              child: ElevatedButton(
                onPressed: () async {
                  await LaunchApp.openApp(
                    androidPackageName: 'com.shenyaocn.android.usbcamera',
                    openStore: true,
                  );
                },
                child: Icon(Icons.camera_alt_outlined),
              ),
            )
        ],
      ),
          )),
    );
  }

  Future uploadToStorage(String uid) async {
    try {
      final DateTime now = DateTime.now();
      final int millSeconds = now.millisecondsSinceEpoch;
      final String month = now.month.toString();
      final String date = now.day.toString();
      final String storageId = (millSeconds.toString() + uid);
      final String today = ('$month-$date');
      ImagePicker img = ImagePicker();
      final Pickedfile = await img.getVideo(source: ImageSource.gallery);
      File file = File(Pickedfile.path);
     

      Reference ref = FirebaseStorage.instance
          .ref()
          .child("video")
          .child(today)
          .child(storageId);
      UploadTask uploadTask =
          ref.putFile(file, SettableMetadata(contentType: 'video/mp4'));

      String url = await uploadTask.then((e) async {
        
        return await ref.getDownloadURL();
      });

      CallMethods cm = CallMethods();
      await cm.addOtoscope(url : url);
      print(url);
    } catch (error) {
      print(error);
    }
  }
}
