import 'package:calidad/model/user.dart' as user;
import 'package:calidad/utils/firebase_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseRepository {
  FirebaseMethods _firebaseMethods = FirebaseMethods();

  Future<User> getCurrentUser() => _firebaseMethods.getCurrentUser();

  Future<User> signIn() => _firebaseMethods.signIn();

  Future<user.User> getUserDetails() => _firebaseMethods.getUserDetails();

  Future<bool> authenticateUser(User user) =>
      _firebaseMethods.authenticateUser(user);

  Future<void> addDataToDb(User user) =>
      _firebaseMethods.addDataToDb(user);

  Future<void> signOut() => _firebaseMethods.signOut();

  Future<List<user.User>> fetchAllUsers(user.User user) =>
      _firebaseMethods.fetchAllUsers(user);

    // Future<List<User>> fetchAllUsers(User user) =>
    //   _firebaseMethods.fetchAllUsers();

 

}