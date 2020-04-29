import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:async/async.dart';
import 'package:amazon_cognito_identity_dart/sig_v4.dart';
import 'package:taled_it/policy.dart';
import 'package:path/path.dart' as path;


  const _accessKeyId = 'AKIAIUQWCDWBJBPTHPBA';
  const _secretKeyId = 'MBmUQj1FxCzJAoG/ZfZWDs9ZagRnuqMtfXsUdc/9';
  const _region = 'ap-south-1';
  const _s3Endpoint = 'https://taleditposts.s3-ap-south-1.amazonaws.com';


class AddPost extends StatefulWidget {
  String accountUser;
  AddPost( this.accountUser );
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {

  String _accountUser;
  
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String currentTime = "00:00";
  String completeTime= "00:00";
  File tale;

  @override
  void initState() {
    super.initState();
    _accountUser = widget.accountUser;

    _audioPlayer.onAudioPositionChanged.listen((Duration duration){
      setState(() {
        currentTime = duration.toString().split(".")[0];
      });
    });

    _audioPlayer.onDurationChanged.listen((Duration duration){
      setState(() {
        completeTime = duration.toString().split(".")[0];
      });
    });

  }

  @override
  void dispose() {
    _audioPlayer.stop();
    super.dispose();
  }
//Upload File to Bucket

  Future fileUpload(File tale) async{
    final stream = http.ByteStream(DelegatingStream.typed(tale.openRead()));
    final length = await tale.length();

    final uri = Uri.parse(_s3Endpoint);
    final req = http.MultipartRequest( "POST", uri);
    final multipartFile = http.MultipartFile( 'file', stream, length,
       filename: path.basename(tale.path));
    String _folder = _accountUser[0].toLowerCase();
    String _newName = _accountUser + _fileName(tale.path);
    final policy = Policy.fromS3PresignedPost('$_folder/$_newName',
      'taleditposts', _accessKeyId, 15, length,
      region: _region);
    final key =
        SigV4.calculateSigningKey(_secretKeyId, policy.datetime, _region, 's3');
    final signature = SigV4.calculateSignature(key, policy.encode());
  
    req.files.add(multipartFile);
    req.fields['key'] = policy.key;
    req.fields['acl'] = 'public-read';
    req.fields['X-Amz-Credential'] = policy.credential;
    req.fields['X-Amz-Algorithm'] = 'AWS4-HMAC-SHA256';
    req.fields['X-Amz-Date'] = policy.datetime;
    req.fields['Policy'] = policy.encode();
    req.fields['X-Amz-Signature'] = signature;

    try {
      final res = await req.send();
      await for (var value in res.stream.transform(utf8.decoder)) {
        print(value);
      }
    } catch (e) {
      print(e.toString());
    }
    updateDB(_folder, _newName);
  }

  final _postKey = GlobalKey<FormState>();

  String _title;
  String _description;
  bool _playerVisible = true;

  String _fileName(String filePath){
    var arr;
    if(filePath != null){
      arr = filePath.split('/');
    }
    return arr[arr.length-1];
  }

  Widget _fileSelect() {
    return Container(
      height: 80,
      width: 80,
      child:FittedBox(
              child: FloatingActionButton(
              backgroundColor: Colors.amber,
              child: Icon(Icons.headset,color: Colors.black,size: 40,),
              onPressed: () async{
                tale = await FilePicker.getFile(type: FileType.AUDIO);
                int status = await _audioPlayer.play(tale.path, isLocal: true);
                if(status == 1){
                  setState(() {
                    _isPlaying = true;
                    _playerVisible = true;
                  });
                }
              },
            ),
      ),
    );
  }


//Title For Tale
  Widget _titleField() {
    return Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 50,
          child: TextFormField(
            onSaved: (value) => _title = value,
            validator: (value) {
              if(value.isEmpty) {
                return "Title is Compulsory.";
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Title of your Tale.',
              hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.black38
                ),
              border: new OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black54,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.amberAccent,
                    width: 2
                  )
                ),
                prefixIcon: Icon(Icons.title,  color: Colors.amberAccent,),
            ),
          ),
        );
  }

//Description Input
  Widget _descriptionField() {
    return Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 50,
            child: TextFormField(
              onSaved: (value) => _description = value,
              obscureText: false,
              validator: (value) {},
              decoration: InputDecoration(
                hintText: 'Description',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.black38
                ),
                border: new OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black54,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.amberAccent,
                    width: 2
                  )
                ),
                prefixIcon: Icon(Icons.description, color: Colors.amberAccent,),
              ),
            ),
          );
  }

//Get Data from URL                    
  Future getJsonData (url) async {
    var response = await http.get(
      Uri.encodeFull(url),
      headers: {"Accept": "application/json"}
    );
    return response;
  }


Future updateDB(String folder, String file) async{
  String objURL = "https://taleditposts.s3.ap-south-1.amazonaws.com/"+folder+"/"+file;
  var addURL = "https://i8ghj2hqua.execute-api.ap-south-1.amazonaws.com/prod/uploadtale?filename="+objURL+"&owner="+_accountUser+"&title="+_title+"&description="+_description;
  var data = await getJsonData(addURL);
}

//Submit Tale 
  Widget _submitPost(double fontSize,int alpha,double width,double height) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
            width: width,
            height: height,
            child: RaisedButton(
                onPressed: (){
                  final form = _postKey.currentState;
                  form.save();
                  if(form.validate()) {
                    fileUpload(tale);
                  }
                },
                color: Colors.black,
                textColor: Colors.amber,
                splashColor: Colors.blueGrey,
                child: Text("Upload", style: TextStyle(fontSize: fontSize),),
              ),
      ),
    );
  }

  // Form Tale Upload
  Widget _formUpload() {

    return Form(
      key: _postKey,
        child: Column(
              children: <Widget>[
                _fileSelect(),
                SizedBox(height:MediaQuery.of(context).size.height*0.02),
                Center(
                  child: Text(
                    ( tale == null ) ? '\t\t\t\t\t\t'+'Select a File'+'\n'+'No Tale Selected': _fileName(tale.path),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                _titleField(),
                SizedBox(
                  height: 8,
                ),
                _descriptionField(),
                SizedBox(
                  height: 8,
                ),
                SizedBox(
                  height: 16,
                ),
                _submitPost(14, 150, 110, 35),
              ],
            ), 
      );
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Heyy $_accountUser, Share A Tale.", style: TextStyle(fontSize: 14),),
          actions: <Widget>[
            Image.asset("assets/logo.png",width: 100,height: 50,color: Colors.white,)
          ],
          backgroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      SizedBox( height: 20 ),
                      Center(child: _formUpload()),
                      SizedBox(height:MediaQuery.of(context).size.height*0.08),
                      (_playerVisible == true)? Container(
                        width: MediaQuery.of(context).size.width*0.9,
                        height: MediaQuery.of(context).size.height*0.1,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(30)
                        ),
                        child: Row(
                          children: <Widget>[
                            SizedBox(width: 10),
                            IconButton(
                              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,color: Colors.amber,size: 30,),
                              onPressed: (){
                                if(_isPlaying){
                                  _audioPlayer.pause();
                                  setState(() {
                                    _isPlaying = false;
                                  });
                                }
                                else{
                                  _audioPlayer.resume();
                                  setState(() {
                                    _isPlaying = true;
                                  });
                                }
                              },
                            ),
                            SizedBox(width: 16,),
                            IconButton(
                              icon: Icon(Icons.stop,color: Colors.amber,size: 30,),
                              onPressed: (){
                                _audioPlayer.stop();
                                setState(() {
                                  _isPlaying = false;
                                });
                              },
                            ),
                            Text(currentTime, style: TextStyle(fontWeight: FontWeight.w700,color: Colors.amber,fontSize: 25),),
                            Text(" | ",style: TextStyle(color:Colors.amber,fontSize: 25),),
                            Text(completeTime, style: TextStyle(fontWeight: FontWeight.w300,color: Colors.amber,fontSize: 25),),
                          ],
                        ),
                      ):Container(),
                    ],
                  ),
                ),
              ),
            );
          }
}