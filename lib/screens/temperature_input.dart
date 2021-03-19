import 'dart:async';
import 'dart:typed_data';

import 'package:calidad/utils/call_methods.dart';

import 'package:calidad/utils/device_utils.dart';
import 'package:flutter/material.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

class Temperature extends StatefulWidget {
  @override
  _TemperatureState createState() => _TemperatureState();
}

class _TemperatureState extends State<Temperature> {
  UsbDevice device;
  double cel;
  double far;
  int counter = 0;
  bool deviceState = false;
  List<String> _stream = [];
  List<UsbDevice> _ports = [];
  List<Widget> _serialData = [];
  bool isLoading = false;

  DeviceUtils dv = DeviceUtils();

  @override
  void initState() {
    super.initState();
    cel = 0;
    far = 0;

    UsbSerial.usbEventStream.listen((UsbEvent event) async {
      _ports = await dv.getPorts();

      setState(() {
        _serialData = [];
        if (_ports.length == 0) {
          device = null;
        } else {
          device = _ports[0];
        }
      });
    });

    _getPorts();
  }

  _getPorts() async {
    _ports = await dv.getPorts();
    setState(() {
      if (_ports.length == 0) {
        device = null;
      } else {
        device = _ports[0];
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void connect(UsbDevice device) async {
    UsbPort _port;
    List res;
    Transaction<String> _transaction;
    StreamSubscription _subscription;

    if (device != null) {
      _port = await device.create();
      if (!await _port.open()) {
        return;
      }
      await _port.setDTR(true);
      await _port.setRTS(true);
      await _port.setPortParameters(
          115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

      _transaction = Transaction.stringTerminated(
          _port.inputStream, Uint8List.fromList([13, 10]));

      _subscription = _transaction.stream.listen((String line) {
        _stream.add(line);
      });

      Timer(Duration(seconds: 5), () {
        _subscription.cancel();
        _transaction = null;
        res = avgTemp(_stream);
        cel = res[0];
        far = res[1];
        CallMethods call = CallMethods();
        call.updateVitals(temp: cel.toString().substring(0, 4));
        setState(() {
          _serialData.add(Text(
            "${cel.toString()}*C",
            style: TextStyle(color: Colors.black),
          ));
          _serialData.add(Text(
            "${far.toString()}*F",
            style: TextStyle(color: Colors.black),
          ));

          deviceState = !deviceState;
        });
        _stream.clear();
      });
    }
  }

  List avgTemp(List<String> stream) {
    int cCounter = 0;
    int fCounter = 0;
    double c = 0;
    double f = 0;
    List res = [];
    int len = stream.length;
    for (int i = 1; i < len; i++) {
      if (stream[i].length > 0) {
        if ((i - 1) % 3 == 0) {
          cCounter++;
          c = c + double.parse(stream[i].substring(12, 16));
        } else if ((i - 2) % 3 == 0) {
          fCounter++;
          f = f + double.parse(stream[i].substring(12, 16));
        }
      }
    }
    c = c / cCounter;
    f = f / fCounter;
    cCounter = 0;
    fCounter = 0;

    res.add(c);
    res.add(f);
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          height: 200,
          padding: EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          child: isLoading
              ? CircularProgressIndicator()
              : device != null
                  ? Container(
                      child: Column(
                        children: [
                          Text("Device Connected"),
                          Container(
                              margin: EdgeInsets.only(bottom: 10),
                              child: !deviceState
                                  ? RaisedButton(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      child: Text("Start"),
                                      onPressed: () async {
                                        setState(() {
                                          _serialData.clear();
                                          deviceState = !deviceState;
                                        });
                                        connect(device);
                                      },
                                    )
                                  : Container(
                                      height: 40,
                                      width: 40,
                                      child: CircularProgressIndicator(),
                                    )),
                          ..._serialData
                        ],
                      ),
                    )
                  : Center(
                      child: Text(
                      "No Device Connected",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ))),
    );
  }
}
