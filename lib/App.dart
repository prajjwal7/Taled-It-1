import 'package:flutter/material.dart';

import 'AddPost/addPost.dart';
import 'Posts/homePage.dart';
import 'Profiles/profile.dart';
import 'Search/search.dart';

//Contains the page-navigation and bottom nav bar.

class App extends StatefulWidget {
  String accountUser;
  App(String accountUser) {
    this.accountUser = accountUser;
  }
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {

  var  accountUser;
  @override
  void initState() {
    accountUser = widget.accountUser;
    _components = [HomePage(accountUser),Search(accountUser),AddPost(accountUser),Profile(accountUser)];
    super.initState();
  }

  int _currentIndex = 0;
  List<bool> _tapped = [true,false,false,false];
  
  PageController pageController = new PageController();
  
  List<Widget> _components;
  
  void _bottomNavBarTap(int index) {
    pageController.jumpToPage(index);
  }

  void _onPageChanged(int index) {
    setState((){
      _currentIndex = index;
      for (int i = 0; i < 4; i++)
        _tapped[i] = (i == index) ? true : false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: PageView(
          controller: pageController,
          onPageChanged: _onPageChanged,
          children: _components,
          physics: NeverScrollableScrollPhysics(),
        ),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon:  Icon(Icons.home,color: _tapped[0] ? Colors.amberAccent : Colors.black, size: 35,),
              title: Text(''),
            ),
            BottomNavigationBarItem(
              icon:  Icon(Icons.search,color: _tapped[1] ? Colors.amberAccent : Colors.black, size: 35,),
              title: Text(''),
            ),
            BottomNavigationBarItem(
              icon:  Icon(Icons.add,color: _tapped[2] ? Colors.amberAccent : Colors.black, size: 35,),
              title: Text(''),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person,color: _tapped[3] ? Colors.amberAccent : Colors.black, size: 35,),
              title: Text(''),
            ),
          ],
          onTap: _bottomNavBarTap,
        ),
      ),
    );
  }
}