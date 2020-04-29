import 'package:flutter/material.dart';

import 'posts.dart';

class HomePage extends StatefulWidget {
  String accountUser;
  HomePage(String accountUser) {
    this.accountUser = accountUser;
  }
  _HomePageState createState() => _HomePageState();
}
//Home Page
class _HomePageState extends State<HomePage> {

  String _accountUser;

  @override
  void initState() {
    super.initState();
    _accountUser = widget.accountUser;
  }

//Owner mini-profile
  Widget _customAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 2),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 10,
          ),
          Text("Welcome, " + _accountUser, style: TextStyle(fontSize: 16)),
          Spacer(),
          Image.asset('assets/logo.png', width: 100,height: 50,)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home:Scaffold(
    //     body: 
    return Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            _customAppBar(),
            Divider(),
            Text("Hello $_accountUser, Hope you are doing great.", style: TextStyle(fontSize: 16),),
            SizedBox(
              height: 15,
            ),
            Posts(_accountUser),
          ]
        );
  }
}