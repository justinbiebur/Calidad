import 'package:calidad/model/user.dart';
import 'package:calidad/provider/user_provider.dart';
import 'package:calidad/screens/pickup_layout.dart';
import 'package:calidad/utils/call_utils.dart';
import 'package:calidad/utils/firebase_methods.dart';
import 'package:calidad/utils/firebase_repository.dart';
import 'package:calidad/utils/permissions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  UserProvider userProvider;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshUser();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return PickupLayout(
        scaffold: Scaffold(
            backgroundColor: Colors.black,
            body: ChatListContainer()));
  }
}

class ChatListContainer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

  final UserProvider userProvider = Provider.of<UserProvider>(context);
  final FirebaseRepository _firebaseRepository = FirebaseRepository();
    return FutureBuilder(
      future: _firebaseRepository.fetchAllUsers(userProvider.getUser),
      builder: (context, docList) {
        print(docList.runtimeType);
        if(docList.hasData){
          return Container(
            child: ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: docList.data.length,
          itemBuilder: (context, index) {
            

            return ContactView(contact: docList.data[index], sender: userProvider.getUser,);
          },
        ));
        }
        else{
          return Container();
        }
        
      },
    );
  }
}

class ContactView extends StatelessWidget {
  final User contact;
  final User sender;

  const ContactView({Key key, @required this.contact, @required this.sender}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: Row(
        children: [
          Text(contact.name),
          SizedBox(width: 50,),
          IconButton(
            icon: Icon(Icons.call, color: Colors.green),
            onPressed: () async =>
              await Permissions.cameraAndMicrophonePermissionsGranted()
                  ? CallUtils.dial(
                      from: sender,
                      to: contact,
                      context: context,
                    )
                  : {},
          )
        ],
      ),
    );
  }
}
