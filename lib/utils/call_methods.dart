import 'package:calidad/model/call.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CallMethods {
  final CollectionReference callCollection = FirebaseFirestore.instance.collection("call");

  Stream<DocumentSnapshot> callStream({String uid}) => 
      callCollection.doc(uid).get().asStream();
      // document(uid).snapshots();

  Future<bool> makeCall({Call call}) async {
    try {
      call.hasDialled = true;
      Map<String, dynamic> hasDialledMap = call.toMap(call);

      call.hasDialled = false;
      Map<String, dynamic> hasNotDialledMap = call.toMap(call);

      await callCollection.doc(call.callerId).set(hasDialledMap);
      await callCollection.doc(call.receiverId).set(hasNotDialledMap);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> updateVitals({String temp}) async {
    try{
      Map<String,dynamic> vitals = Map();
      vitals["temperature"] = temp;
      await callCollection.doc("data").set(vitals);
      return true;
    }catch(e){
      return false;
    }
  }

  Future<bool> deleteData()async {
    try{
      await callCollection.doc("data").delete();
      return true;
    }catch(e){
      return false;
    }
  }

  Future<bool> endCall({Call call}) async {
    try {
      await callCollection.doc(call.callerId).delete();
      await callCollection.doc(call.receiverId).delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> pauseCall({Call call}) async {
    try {
      await callCollection.doc(call.callerId).delete();

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> resumeCall({Call call}) async {
    try{
      call.hasDialled = true;
      Map<String, dynamic> hasDialledMap = call.toMap(call);
      await callCollection.doc(call.callerId).set(hasDialledMap);
      return true;
    }catch(e){
      print(e);
      return false;
    }
  }
}