import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:usb_serial/usb_serial.dart';

class DeviceUtils {

  // final PermissionHandler _permissionHandler = PermissionHandler();

  Future<List<UsbDevice>> getPorts() async {
    List<UsbDevice> devices = [];
    devices = await UsbSerial.listDevices();
    return devices;
  }
  // Future<bool> requestPermission(PermissionGroup permission) async {
  //   var result = await _permissionHandler.requestPermissions([permission]);
  //   if (result[permission] == PermissionStatus.granted) {
  //     print("true");
  //     return true;
  //   }
  //   print("false");
  //   return false;
  // }
  // 
}
