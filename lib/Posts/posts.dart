import 'dart:convert';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:core';
import 'package:http/http.dart' as http;

import 'jsonPost.dart';


// Tale Layout
class Posts extends StatefulWidget {
  String accountUser;
  Posts(this.accountUser);
  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Posts> {

  String accountUser;
  var data;

  double rating = 1;
  String filePath;

  var tales = new List<jsonPost>();

  getRequest() {
    return this._memoizer.runOnce(() async {
      String postURL = "https://i8ghj2hqua.execute-api.ap-south-1.amazonaws.com/prod/tales?owner="+accountUser;
      data = http.get(
        Uri.encodeFull(postURL),
        headers: {"Accept": "application/json"}
      );
      _getTales();
      return data;
    });
  }

//AsyncMemoizer for caching the response
  final AsyncMemoizer _memoizer = AsyncMemoizer();

//Convert To List Of Objects                    
  _getTales(){
    data.then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        tales = list.map((model) => jsonPost.fromJson(model)).toList();
      });
    });
  }


  @override
  void initState() {
    super.initState();
    accountUser = widget.accountUser;
  }


  String getDate(String s){
    return s[0]+s[1]+s[2]+s[3]+s[4]; 
  }

  void _reflectRating(int index) async{
    var rateURL = "https://i8ghj2hqua.execute-api.ap-south-1.amazonaws.com/prod/rate?owner="+accountUser+"&postID="+tales[index].postID.toString()+"&rated="+tales[index].yourRating.toString(); 
    var rateData = await http.get(
      Uri.encodeFull(rateURL),
      headers: {"Accept": "application/json"}
    );
    print(rateData.body[0]);
  }
  
  Widget _eachTale(index) {

    tales[index].player.onAudioPositionChanged.listen((Duration duration){
      setState(() {
        tales[index].currentTime = duration.toString().split(".")[0];
      });
    });
    

    tales[index].player.onDurationChanged.listen((Duration duration){
      setState(() {
        tales[index].completeTime = duration.toString().split(".")[0];
      });
    });

    return Padding(
      padding: const EdgeInsets.only(bottom:16.0),
      child: Card(
        elevation: 15,
        child:Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height*0.08,
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left:35.0),
                    child: Text(
                      tales[index].postOwner,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left:20.0),
                    child: Text(
                      tales[index].place,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  Spacer(),
                  Text(
                    getDate(tales[index].postTime),
                  ),
                  SizedBox(width:50)
                ],
              ),
            ),
            Stack(
              children:<Widget>[
                Column(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: MediaQuery.of(context).size.width*0.975,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: tales[index].profilePic == 'default' ? 
                          AssetImage('assets/default.jpg') : NetworkImage(tales[index].profilePic),
                      ),
                    ),
                  ),
                ],
                ),
                Positioned(
                  top:MediaQuery.of(context).size.height*0.3,
                  child: Visibility(
                    visible: tales[index].showSlider,
                    child:Container(
                      width: MediaQuery.of(context).size.width,
                      child: Slider(
                          value: rating,
                          min:1,
                          max: 10,
                          divisions: 9,
                          label: '$rating',
                          inactiveColor: Colors.amber,
                          activeColor: Colors.amber,
                          onChanged:(double value){
                            setState(() {
                              rating = value;
                              tales[index].yourRating = rating;
                            });
                          },
                          onChangeEnd: (double value) {
                            if(tales[index].yourRating > 0) {
                              _reflectRating(index);
                              setState((){
                                tales[index].allowRating = false;
                                tales[index].showSlider = false;
                              });
                            }
                          }
                        ),
                    ),
                  ),
                ),
                 Positioned(
                  top:MediaQuery.of(context).size.height*0.3, 
                  child: Visibility(
                      visible: tales[index].showDesc,
                      child:Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height*0.1,
                        decoration: BoxDecoration(
                          color:Color.fromARGB(150, 255, 255,255) 
                        ),
                        child: Center(
                          child: Text(
                            tales[index].description,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                 ),
                Positioned(
                  top:MediaQuery.of(context).size.height*0.4,
                  child: Container(
                    decoration: BoxDecoration(
                      color:Color.fromARGB(150, 255, 255,255) 
                    ),
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left:8.0),
                              child: Text(
                                tales[index].title,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight:FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              tales[index].rating.toString() + "/10",
                            ),
                          ],
                        ),
                        Padding(padding: EdgeInsets.only(left:100)),
                        Visibility(
                          visible: tales[index].allowRating,
                          child: IconButton(
                            icon: Icon(Icons.star), 
                            onPressed: (){
                              setState(() {
                                tales[index].showSlider = !tales[index].showSlider;
                                tales[index].showDesc = false;
                              });
                          }),
                        ),
                        IconButton(icon: Icon(Icons.info , ), 
                            onPressed: (){
                              setState(() {
                                tales[index].showDesc = !tales[index].showDesc;
                                tales[index].showSlider = false;
                              });
                            }),
                      ],
                    ),
                  ),
                ),
              ]
            ),
            Container(
              height: MediaQuery.of(context).size.height*0.1,
              decoration: BoxDecoration(
                color: Colors.black
              ),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom:20),
                    child: IconButton(
                      icon: Icon(tales[index].isPlaying ? Icons.pause : Icons.play_arrow,color: Colors.amber,size: 44,),
                      onPressed: (){
                        if(tales[index].isPlaying){
                          tales[index].player.pause();
                          setState(() {
                            tales[index].isPlaying = false;
                          });
                        }
                        else{
                          tales[index].player.play(tales[index].fileName);
                          setState(() {
                            tales[index].isPlaying = true;
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(width:20),
                  Padding(
                    padding: const EdgeInsets.only(bottom:20),
                    child: IconButton(
                      icon: Icon(Icons.stop,color: Colors.amber,size: 45,),
                      onPressed: (){
                        tales[index].player.stop();
                        setState(() {
                          tales[index].isPlaying = false;
                        });
                      },
                    ),
                  ),
                  SizedBox(width:50),
                  Padding(
                    padding: const EdgeInsets.only(top:0),
                    child: Text(tales[index].currentTime, style: TextStyle(fontWeight: FontWeight.w700,color: Colors.amber,fontSize:22),),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:0),
                    child: Text(" | ",style: TextStyle(color:Colors.amber,fontSize: 24),),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:0),
                    child: Text(tales[index].completeTime, style: TextStyle(fontWeight: FontWeight.w300,color: Colors.amber,fontSize: 22),),
                  ),
                ],
              ),
            ),
          ],
        ),                                                              
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder <dynamic> (
      future: getRequest(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
        if(snapshot.hasData){
            return Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: tales.length,
                itemBuilder: (context, index) {
                  return _eachTale(index);
                },
              ),
            );
        }
        else if(snapshot.hasError){
          return
            Padding(
              padding: EdgeInsets.all(10),
              child: Text("Error Loading Tales. Please Try Again Later", style: TextStyle(fontSize: 12, color: Colors.redAccent),),
            );
        }
        else {
          return 
            SizedBox(
              child: CircularProgressIndicator(backgroundColor: Colors.amber),
              height: 60,
              width: 60  
            );
        }
      }
    );
  }
}