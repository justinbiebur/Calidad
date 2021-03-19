// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:path_provider/path_provider.dart';

// class RecorderView extends StatefulWidget {
//   final Function onSaved;

//   const RecorderView({Key key, @required this.onSaved}) : super(key: key);
//   @override
//   _RecorderViewState createState() => _RecorderViewState();
// }

// enum RecordingState {
//   UnSet,
//   Set,
//   Recording,
//   Stopped,
// }

// class _RecorderViewState extends State<RecorderView> {
//   IconData _recordIcon = Icons.mic_none;
//   FlutterSound flutterSound = new FlutterSound();
//   String _recordText = 'Click To Start';
//   RecordingState _recordingState = RecordingState.UnSet;

  

//   @override
//   void initState() {
//     super.initState();

    
//   }

//   @override
//   void dispose() {
//     _recordingState = RecordingState.UnSet;
    
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         RaisedButton(
//           onPressed: () async {
//             await _onRecordButtonPressed();
//             setState(() {});
//           },
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(100),
//           ),
//           child: Container(
//             width: 50,
//             height: 50,
//             child: Icon(
//               _recordIcon,
//               size: 20,
//             ),
//           ),
//         ),
//         Align(
//             alignment: Alignment.bottomCenter,
//             child: Padding(
//               child: Text(_recordText),
//               padding: const EdgeInsets.all(8),
//             ))
//       ],
//     );
//   }

//   Future<void> _onRecordButtonPressed() async {
//     switch (_recordingState) {
//       case RecordingState.Set:
//         await _recordVoice();
//         break;

//       case RecordingState.Recording:
//         await _stopRecording();
//         _recordingState = RecordingState.Stopped;
//         _recordIcon = Icons.fiber_manual_record;
//         _recordText = 'Record new one';
//         break;

//       case RecordingState.Stopped:
//         await _recordVoice();
//         break;

//       case RecordingState.UnSet:
//         Scaffold.of(context).hideCurrentSnackBar();
//         Scaffold.of(context).showSnackBar(SnackBar(
//           content: Text('Please allow recording from settings.'),
//         ));
//         break;
//     }
//   }

//   _initRecorder() async {
//     Directory appDirectory = await getApplicationDocumentsDirectory();
//     String filePath = appDirectory.path +
//         '/' +
//         DateTime.now().millisecondsSinceEpoch.toString() +
//         '.aac';

//     audioRecorder =
//         FlutterAudioRecorder(filePath, audioFormat: AudioFormat.AAC);
//     await audioRecorder.initialized;
//   }

//   _startRecording() async {
//     await audioRecorder.start();
//   }

//   _stopRecording() async {
//     await audioRecorder.stop();

//     widget.onSaved();
//   }

//   Future<void> _recordVoice() async {
//     if (await FlutterAudioRecorder.hasPermissions) {
//       await _initRecorder();

//       await _startRecording();
//       _recordingState = RecordingState.Recording;
//       _recordIcon = Icons.stop;
//       _recordText = 'Recording';
//     } else {
//       Scaffold.of(context).hideCurrentSnackBar();
//       Scaffold.of(context).showSnackBar(SnackBar(
//         content: Text('Please allow recording from settings.'),
//       ));
//     }
//   }
// }