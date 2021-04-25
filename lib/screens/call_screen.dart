import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:calidad/config/agora_config.dart';
import 'package:calidad/model/call.dart';
import 'package:path_provider/path_provider.dart';
import 'package:calidad/provider/user_provider.dart';


import 'package:calidad/utils/call_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';

class CallScreen extends StatefulWidget {
  final Call call;

  CallScreen({
    @required this.call,
  });

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallMethods callMethods = CallMethods();
  String bottomModalState = 'Vitals';

  UserProvider userProvider;
  StreamSubscription callStreamSubscription;

  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;

  @override
  void initState() {
    super.initState();

    addPostFrameCallback();
    initializeAgora();
  }

  Future<void> initializeAgora() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    await AgoraRtcEngine.setParameters(
        '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
    await AgoraRtcEngine.joinChannel(null, widget.call.channelId, null, 0);
  }

  addPostFrameCallback() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      userProvider = Provider.of<UserProvider>(context, listen: false);

      callStreamSubscription = callMethods
          .callStream(uid: userProvider.getUser.uid)
          .listen((DocumentSnapshot ds) {
        // defining the logic
        switch (ds.data) {
          case null:
            // snapshot is null which means that call is hanged and documents are deleted
            // Navigator.pop(context);
            break;

          default:
            break;
        }
      });
    });
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    await AgoraRtcEngine.create(APP_ID);
    await AgoraRtcEngine.enableVideo();
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        final info = 'onUserJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
    };

    AgoraRtcEngine.onUpdatedUserInfo = (AgoraUserInfo userInfo, int i) {
      setState(() {
        final info = 'onUpdatedUserInfo: ${userInfo.toString()}';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onRejoinChannelSuccess = (String string, int a, int b) {
      setState(() {
        final info = 'onRejoinChannelSuccess: $string';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onUserOffline = (int a, int b) {
      callMethods.endCall(call: widget.call);
      setState(() {
        final info = 'onUserOffline: a: ${a.toString()}, b: ${b.toString()}';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onRegisteredLocalUser = (String s, int i) {
      setState(() {
        final info = 'onRegisteredLocalUser: string: s, i: ${i.toString()}';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    };

    AgoraRtcEngine.onConnectionLost = () {
      setState(() {
        final info = 'onConnectionLost';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      // if call was picked

      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    };
    

    AgoraRtcEngine.onFirstRemoteVideoFrame = (
      int uid,
      int width,
      int height,
      int elapsed,
    ) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    };
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<AgoraRenderWidget> list = [
      AgoraRenderWidget(0, local: true, preview: true),
    ];
    _users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[1]]),
            _expandedVideoRow([views[0]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  /// Info panel to show logs
  // Widget _panel() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 48),
  //     alignment: Alignment.bottomCenter,
  //     child: FractionallySizedBox(
  //       heightFactor: 0.5,
  //       child: Container(
  //         padding: const EdgeInsets.symmetric(vertical: 48),
  //         child: ListView.builder(
  //           reverse: true,
  //           itemCount: _infoStrings.length,
  //           itemBuilder: (BuildContext context, int index) {
  //             if (_infoStrings.isEmpty) {
  //               return null;
  //             }
  //             return Padding(
  //               padding: const EdgeInsets.symmetric(
  //                 vertical: 3,
  //                 horizontal: 10,
  //               ),
  //               child: Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Flexible(
  //                     child: Container(
  //                       padding: const EdgeInsets.symmetric(
  //                         vertical: 2,
  //                         horizontal: 5,
  //                       ),
  //                       decoration: BoxDecoration(
  //                         color: Colors.yellowAccent,
  //                         borderRadius: BorderRadius.circular(5),
  //                       ),
  //                       child: Text(
  //                         _infoStrings[index],
  //                         style: TextStyle(color: Colors.blueGrey),
  //                       ),
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    AgoraRtcEngine.switchCamera();
  }

  /// Toolbar layout
  Widget _toolbar(BuildContext ctx)  {


    Future<String> _localPath() async{
  final directory=await getExternalStorageDirectory();
  return directory.path;
}

// List<List<int>> audioData=[];

// Future<void> save(List<int> data, int sampleRate,String path) async {
//     File recordedFile = File(path);

//     var channels = 1;

//     int byteRate = ((16 * sampleRate * channels) / 8).round();

//     var size = data.length;

//     var fileSize = size + 36;

//     Uint8List header = Uint8List.fromList([
//       // "RIFF"
//       82, 73, 70, 70,
//       fileSize & 0xff,
//       (fileSize >> 8) & 0xff,
//       (fileSize >> 16) & 0xff,
//       (fileSize >> 24) & 0xff,
//       // WAVE
//       87, 65, 86, 69,
//       // fmt
//       102, 109, 116, 32,
//       // fmt chunk size 16
//       16, 0, 0, 0,
//       // Type of format
//       1, 0,
//       // One channel
//       channels, 0,
//       // Sample rate
//       sampleRate & 0xff,
//       (sampleRate >> 8) & 0xff,
//       (sampleRate >> 16) & 0xff,
//       (sampleRate >> 24) & 0xff,
//       // Byte rate
//       byteRate & 0xff,
//       (byteRate >> 8) & 0xff,
//       (byteRate >> 16) & 0xff,
//       (byteRate >> 24) & 0xff,
//       // Uhm
//       ((16 * channels) / 8).round(), 0,
//       // bitsize
//       16, 0,
//       // "data"
//       100, 97, 116, 97,
//       size & 0xff,
//       (size >> 8) & 0xff,
//       (size >> 16) & 0xff,
//       (size >> 24) & 0xff,
//       ...data
//     ]);
//     return recordedFile.writeAsBytesSync(header, flush: true);
//   }
    // StreamSubscription<List<int>> listener;
    
    FlutterAudioRecorder recorder;
    
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic : Icons.mic_off,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () {
              callMethods.endCall(
                call: widget.call,
              );
              CallMethods call = CallMethods();
              call.deleteData();
              Navigator.pop(context);
            },
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: ()async{
              // await listener.cancel();
              //  List<int> flat=audioData.expand((element) => element).toList();
              //  print(flat);
              //  var filename=await _localPath();
              // var createdFile=File(filename+'/data.wav').create(recursive: true);
              // await save(flat, 44100, filename+'/data.wav');
              // 
              // 
              await recorder.stop();

              },
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () async {
              
              var filename=await _localPath();
               // sampleRate is 16000 by default
              recorder=FlutterAudioRecorder(filename+'/data.wav',sampleRate: 22000,audioFormat: AudioFormat.WAV);
              await recorder.initialized;
              await recorder.start();
              
              // // Init a new Stream
              //     Stream<List<int>> stream = await MicStream.microphone(sampleRate: 44100);
              //     print("stream ");
              //     // Start listening to the stream
              //      listener = stream.listen((samples){audioData.add(samples); });
  
            },
            child: Icon(
              Icons.pending_actions_rounded,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    callStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            // _panel(),
            _toolbar(context),
          ],
        ),
      ),
    );
  }
}
