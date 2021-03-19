
import 'package:calidad/provider/user_provider.dart';
import 'package:calidad/screens/home_screen.dart';
import 'package:calidad/screens/login_screen.dart';
import 'package:calidad/utils/firebase_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main()async  {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
} 

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() { 
    super.initState();
    Firebase.initializeApp();
  }

  final FirebaseMethods _authMethods = FirebaseMethods();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: "Flutter",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(brightness: Brightness.dark),
        home:  FutureBuilder(
            future: _authMethods.getCurrentUser(),
            builder: (context, AsyncSnapshot<User> snapshot) {
              if (snapshot.hasData) {
                return HomeScreen();
              } else {
                return LoginScreen();
              }
            },
          
        ),
      ),
    );
  }
}
