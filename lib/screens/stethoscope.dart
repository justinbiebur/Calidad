import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';


class Stethoscope extends StatefulWidget {

  @override
  _StethoscopeState createState() => _StethoscopeState();
}

class _StethoscopeState extends State<Stethoscope> {
  Directory appDirectory;
  Stream<FileSystemEntity> fileStream;
  List<String> records;

  @override
  void initState() {
    super.initState();
    records = [];
    getApplicationDocumentsDirectory().then((value) {
      appDirectory = value;
      appDirectory.list().listen((onData) {
        print("Path"+onData.path);
        if(onData.path.endsWith(".aac")){
        records.add(onData.path);
        }
      }).onDone(() {
        records = records.reversed.toList();
        setState(() {});
      });
    });
    
  }

  @override
  void dispose() {
    fileStream = null;
    appDirectory = null;
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Stethoscope"),
      ),
      body: Column(
        children: [
          Container(           
            height: 300,
            // child: RecordListView(
            //   records: records,
            // ),
            child: Container(),
          ),
          Container(
            height: 100,
            // 
            child: Container(),
          ),
        ],
      ),
    );
  }

  _onRecordComplete() {
    records.clear();
    appDirectory.list().listen((onData) {
      if(onData.path.endsWith(".aac")){
        records.clear();
        records.add(onData.path);
        }
    }).onDone(() {
      records.sort();
      records = records.reversed.toList();
      setState(() {});
    });
  }
}