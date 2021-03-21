import 'package:calidad/model/user.dart' as user;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';


class FirebaseMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final CollectionReference _userCollection =
      _firestore.collection("user");

  

  
  user.User us= new user.User();
  Future<User > getCurrentUser() async {
    User currentUser;
    currentUser =  _auth.currentUser;

    return currentUser;
  }

  Future<user.User> getUserDetails() async {
    User currentUser = await getCurrentUser();
    DocumentSnapshot documentSnapshot =
        await _userCollection.doc(currentUser.uid).get();
        
    return user.User.fromMap(documentSnapshot.data());
  }

  Future<User> signIn() async {
    // GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
    // GoogleSignInAuthentication _signInAuthentication =
    //     await _signInAccount.authentication;

    // final AuthCredential credential = GoogleAuthProvider.credential(
    //     accessToken: _signInAuthentication.accessToken,
    //     idToken: _signInAuthentication.idToken);

    // UserCredential authResult = await _auth.signInWithCredential(credential);
    // User user = authResult.user;
    // return user;
    UserCredential authResult= await _auth.signInWithEmailAndPassword(email:"demouser@gmail.com", password: "123456789");
    User user=authResult.user;
    return user;
  }

  Future<bool> authenticateUser(User user) async {
    QuerySnapshot result = await _firestore
        .collection("user")
        .where("email", isEqualTo: user.email)
        .get();

    final List<DocumentSnapshot> docs = result.docs;

    return docs.length == 0 ? true : false;
  }

  Future<void> addDataToDb(User currentUser) async {
    String username = currentUser.email.split('@')[0];
    
    user.User cUser = user.User(
        uid: currentUser.uid,
        email: currentUser.email,
        name: currentUser.displayName,
        profilePhoto: currentUser.photoURL,
        username: username);

    
    _firestore
        .collection("user")
        .doc(currentUser.uid)
        .set(us.toMap(cUser));
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    return await _auth.signOut();
  }

  Future<List<user.User>> fetchAllUsers(user.User currentUser) async {
    List<user.User> userList = List<user.User>();

    QuerySnapshot querySnapshot =
        await _firestore.collection("user").get();

        print("QS ${querySnapshot.docs.length}");
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id != currentUser.uid) {
        userList.add(user.User.fromMap(querySnapshot.docs[i].data()));
      }
    }
    return userList;
  }

  // Future<List<User>> fetchAllUsers() async {
  //   List<User> userList = List<User>();

  //   QuerySnapshot querySnapshot =
  //       await firestore.collection("docotrs").getDocuments();

  //       print("QS ${querySnapshot.documents.length}");
  //   for (var i = 0; i < querySnapshot.documents.length; i++) {
  //       userList.add(User.fromMap(querySnapshot.documents[i].data));
  //   }
  //   return userList;
  // }
}
