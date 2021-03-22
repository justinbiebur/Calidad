import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:calidad/provider/user_provider.dart';
import 'package:provider/provider.dart';

class Stethoscope extends StatefulWidget {
  @override
  _StethoscopeState createState() => _StethoscopeState();
}

class _StethoscopeState extends State<Stethoscope> {
  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  bool _mRecorderIsInited = false;
  bool _isUploading=false;
 

  @override
  void initState() {
    super.initState();

    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _mRecorder.closeAudioSession();
    _mRecorder = null;
    super.dispose();
  }

  Future<void> openTheRecorder() async {
    print("open recorder called");
    var status = (await PermissionHandler().requestPermissions(
        [PermissionGroup.microphone]))[PermissionGroup.microphone];

    print(status);
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    status = (await PermissionHandler().requestPermissions(
        [PermissionGroup.storage]))[PermissionGroup.storage];


    await _mRecorder.openAudioSession();
    _mRecorderIsInited = true;
  }
Future<String> get _localPath async{
  final directory=await  getExternalStorageDirectory();
  return directory.path;
}

  void record() async{
    print("record called");
    String dir=await _localPath;
    _mRecorder
        .startRecorder(
      toFile: dir+'test.aac',
      //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
    )
        .then((value) {
      setState(() {});
    });
  }

  void stopRecorder() async {
    await _mRecorder.stopRecorder().then((value) {
      setState(() {
        //var url = value;
      });
    });
  }

  getRecorderFn() {
    if (!_mRecorderIsInited) {
      return null;
    }
    print(_mRecorder.isStopped);
    return _mRecorder.isStopped ? record : stopRecorder;
  }

  @override
  Widget build(BuildContext context) {
 final UserProvider user = Provider.of<UserProvider>(context);
    String uid = user.getUser.uid;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Stethoscope"),
      ),
      
      body: Container(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
            Container(
              child: ElevatedButton(
                onPressed: (){
                  
                  getRecorderFn()();
                },
                child: Text(_mRecorder.isRecording ? 'Stop' : 'Record'),
              ),
            ),
            Container(
              child: ElevatedButton(
                onPressed:_isUploading?null: () async {
                 uploadToStorage(uid);
                },
                child: Icon(Icons.upload_rounded)
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
      String dir=await _localPath;
      
      File file = File(dir+'test.aac');
      
      print("File exists at ${dir}test.aac  ?");
      print(await file.exists());
      _isUploading=true;
      setState(() {});
      Reference ref = FirebaseStorage.instance
          .ref()
          .child("audio")
          .child(today)
          .child(storageId);
      UploadTask uploadTask =
          ref.putFile(file, SettableMetadata(contentType: 'audio/aac'));

      String url = await uploadTask.then((e) async {
        
        return await ref.getDownloadURL();
      });
      print(url);
      _isUploading=false;
      setState(() {
        
      });

    } catch (error) {
      _isUploading=false;
      print(error);
      setState(() {
        
      });
    }
  }

}
