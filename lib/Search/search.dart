import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:core';

import 'jsonMates.dart';

class Search extends StatefulWidget {
  String accountUser;
  Search(this.accountUser);
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {

  
  String accountUser;
  @override
  void initState() {
    accountUser = widget.accountUser;
    super.initState();
  }

  Future getJsonData (url) async {
    var response = await http.get(
      Uri.encodeFull(url),
      headers: {"Accept": "application/json"}
    );
    return response;
  }

  String searchURL = "https://i8ghj2hqua.execute-api.ap-south-1.amazonaws.com/prod/search?search=";
  var data;
  bool search = false;
  TextEditingController _controller = new TextEditingController();
  var searched = new List<jsonMates>();

//Displays the Search Bar  
  Widget _searchBar() {
    return AppBar(
      backgroundColor: Colors.white,
      flexibleSpace: Container(
        height: 80,
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(15, 10, 0, 5),
              width: MediaQuery.of(context).size.width * 0.85,
              child: TextField(
                controller: _controller,
               style: TextStyle(
                 color: Colors.white,
                 height: 2
               ),
               onTap: () {
                  setState((){
                    searched = [];
                    search = false;
                  });
               },
               cursorColor: Colors.amber,
               decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.white54
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white60,
                      width: 2
                    )
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.amber,
                      width: 2
                    ),
                  ),
                  prefixIcon: Icon(Icons.people, color: Colors.amber, size: 30) 
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.search, 
                size: 30,
                color: Colors.amber,
              ), 
              onPressed: () {
                if(_controller.text != null){
                  var searchURLF = searchURL + _controller.text + "&owner=" + accountUser;
                  data = getJsonData(searchURLF);
                    data.then((response) {
                      setState( () {
                          Iterable list = json.decode(response.body);
                          searched = list.map((model) => jsonMates.fromJson(model)).toList();
                          search = true;
                       }); 
                    }); 
              }
              }
            ),
          ],
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.black45]
          )
        ),
      ),
    );
  }

  Future updatefollowDB(String name, int index) async {
    print("I am in");
    var followURL = "https://i8ghj2hqua.execute-api.ap-south-1.amazonaws.com/prod/follow?owner="+accountUser+"&followed="+name;
    var response = await http.get(
      Uri.encodeFull(followURL),
      headers: {"Accept": "application/json"}
    );
    setState(() {
      searched[index].status = "Following";
    });
  }

  Widget _searchResult(index) {
    return Card(
          child: Column(children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.width ,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: (searched[index].profile != 'default') 
                      ? NetworkImage(searched[index].profile) 
                      : AssetImage("assets/default.jpg"),
                  ),
                ),
            ),
            Center(
              child: Row(
              children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(12,14,0,10),
                child: Icon(Icons.music_note,color: Colors.amber,size: 30,),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(2,14.0,0,10),
                child: Text(
                  searched[index].name,
                  style: TextStyle(fontSize: 18),  
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(2,16,10,10),
                child: Text("( "+ searched[index].place +" )"),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(right:16.0),
                child: RaisedButton(
                  onPressed: (){
                    if(searched[index].status == "Follow") {
                      updatefollowDB(searched[index].name, index);
                    }
                  },
                  color: Colors.amber,
                  child: Text(searched[index].status, style: TextStyle(color: Colors.black),),
                ),
              )
            ],
          ),
        ),
      ],
     ),
    );
  }
//Displays the Recommendations

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: _searchBar(),
        body: 
        (search)?
        Column(
          children: <Widget>[    
            Expanded(
              child: ListView.builder(
              shrinkWrap: true,
              itemCount: searched.length,
              itemBuilder: (context, index) {
                return _searchResult(index);
              },
            ),
            ),
          ]
        ):Center(
            child: Image.asset("assets/searchPage.png", height: 150, width: 150,),  
          ),
      ),
    );    
  }
}