import 'package:calidad/model/call.dart';
import 'package:calidad/screens/call_screen.dart';
import 'package:calidad/screens/otoscope.dart';
import 'package:calidad/screens/stethoscope.dart';
import 'package:calidad/screens/temperature_input.dart';
import 'package:calidad/utils/call_methods.dart';
import 'package:flutter/material.dart';

class VitalScreen extends StatelessWidget {
  final Call call;

  const VitalScreen({Key key, @required this.call}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    CallMethods callMethod = CallMethods();
    return WillPopScope(
      onWillPop: () async {
        bool callResume = await callMethod.resumeCall(call: call);
        if (callResume) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CallScreen(call: call),
              ));
              
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            padding: EdgeInsets.all(20),
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  child: RawMaterialButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Temperature()));
                    },
                    child: Icon(
                      Icons.thermostat_sharp,
                      color: Colors.black,
                      size: 40.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 2.0,
                    fillColor: Colors.white,
                    padding: const EdgeInsets.all(12.0),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  child: RawMaterialButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Stethoscope()));
                    },
                    child: Icon(
                      Icons.medical_services_outlined,
                      color: Colors.black,
                      size: 40.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 2.0,
                    fillColor: Colors.white,
                    padding: const EdgeInsets.all(12.0),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  child: RawMaterialButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Otoscope()));
                    },
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.black,
                      size: 40.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 2.0,
                    fillColor: Colors.white,
                    padding: const EdgeInsets.all(12.0),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
