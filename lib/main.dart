import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';


import 'App.dart';
import 'login.dart';

void main() =>  
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Padding(
        padding: EdgeInsets.only(top:100),
        child: SplashScreen(
          backgroundColor: Colors.white10,
          seconds: 2,
          loaderColor: Colors.white10,
          image: Image.asset('assets/logo.png',scale: 0.6,),
          photoSize: 150,
          navigateAfterSeconds:StateFulTaled_it(),
        ),
      ),
    ),
  )
);


class StateFulTaled_it extends StatefulWidget {
  @override
  Taled_it createState() => Taled_it();
}

class Taled_it extends State<StateFulTaled_it> {

  int _loggedIn;
  String _accountUser;
  
  @override
  void initState() {
    super.initState();
    restore();
  }

  Future restore() async {
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    setState(() {
      _accountUser = sharedPrefs.getString('accountUser');
      _loggedIn = sharedPrefs.getInt('loggedIn');
    });
    print(_loggedIn);
    print(_accountUser);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Taled_It",
      home: Scaffold( 
        body: (_loggedIn == 1)?App(_accountUser) : Login(),
      ),
    );    
  }
}