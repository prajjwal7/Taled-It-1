import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:core';
import 'package:image_picker/image_picker.dart';
import 'package:taled_it/login.dart';
import 'jsonProfile.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:amazon_cognito_identity_dart/sig_v4.dart';
import 'package:taled_it/policy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'jsonPersonalPosts.dart';


const _accessKeyId = '';
const _secretKeyId = '';
const _region = '';
const _s3Endpoint = '';

class Profile extends StatefulWidget{
  String accountUser;
  Profile(this.accountUser);
  @override
  State<StatefulWidget> createState() {
    return _ProfilePage();
  }
}

class _ProfilePage extends State<Profile>{

  String accountUser;
  var profile = new List<jsonProfile>();
  var data;
  bool talesVisible = false;

  final AsyncMemoizer _memoizer = new AsyncMemoizer();
  final AsyncMemoizer _memoizerTales = new AsyncMemoizer();

  _getRequest() {
    // return this._memoizer.runOnce(() async {
      String profileURL = "https://i8ghj2hqua.execute-api.ap-south-1.amazonaws.com/prod/profile?owner="+accountUser;
      data = http.get(
        Uri.encodeFull(profileURL),
        headers: {"Accept": "application/json"}
    );
    _getProfile();
    return data;
    // });
  }

  var talesData;
  var personalTales = new List<jsonPersonalPosts>();

   _getPersonalTales() async {
     print(accountUser);
      String personalURL = "https://i8ghj2hqua.execute-api.ap-south-1.amazonaws.com/prod/personaltales?owner=" + accountUser;
      talesData = await http.get(
          Uri.encodeFull(personalURL),
          headers: {"Accept": "application/json"}
      );
      await _getTales();
      return talesData;
  }


  Future fileUpload(File profileImage) async{
    //final file = File('assets/s1.jpg');
    // File file = await FilePicker.getFile(type: FileType.AUDIO);
    // File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    final stream = http.ByteStream(DelegatingStream.typed(profileImage.openRead()));
    final length = await profileImage.length();

    final uri = Uri.parse(_s3Endpoint);
    final req = http.MultipartRequest( "POST", uri);
    final multipartFile = http.MultipartFile( 'file', stream, length,
       filename: path.basename(profileImage.path));
    String _folder = accountUser[0].toLowerCase();
    String _newName = accountUser + "." +  _fileName(profileImage.path);
    final policy = Policy.fromS3PresignedPost('$_folder/$_newName',
      'taleditpics', _accessKeyId, 15, length,
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

//Get Data from URL                    
  Future getJsonData(url) async {
    var response = await http.get(
      Uri.encodeFull(url),
      headers: {"Accept": "application/json"}
    );
    return response;
  }


  Future updateDB(String folder, String file) async{
    String objURL = "https://taleditpics.s3.ap-south-1.amazonaws.com/"+folder+"/"+file;
    var addURL = "https://i8ghj2hqua.execute-api.ap-south-1.amazonaws.com/prod/updatedp?profilePic="+objURL+"&owner="+accountUser;
    var data = await getJsonData(addURL);
  }

//Get Data from URL                    
  _getProfile() async{
    await data.then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        profile = list.map((model) => jsonProfile.fromJson(model)).toList();
      });
    });
  }

  _getTales() {
     talesData.then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        personalTales = list.map((model) => jsonPersonalPosts.fromJson(model)).toList();
      });
    });
    return personalTales;
  }
  
  String _fileName(String filePath){
    var arr;
    if(filePath != null){
      arr = filePath.split('.');
    }
    return arr[arr.length-1];
  }
  
  @override
  void initState(){
    super.initState();
    accountUser = widget.accountUser;
    _getPersonalTales();
  }

  File _image;

  Future showChoiceDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose From : "),
          content: SingleChildScrollView(
           child: ListBody(
             children: <Widget>[
                GestureDetector(
                  child: Text("Gallery"),
                  onTap: () => openGallery(context),
                ),
                Padding(padding: EdgeInsets.all(10),),
                GestureDetector(
                 child: Text("Camera"),
                 onTap: () => openCamera(context),
               ),
             ],
           ), 
          ),
        );
      }   
    );
  }




  Future openCamera(context) async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
    fileUpload(_image);
  }

  Future openGallery(context) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
    fileUpload(_image);
  }

Widget _buildprofileImage(Size size){
  return(
    Stack(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Align(
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.only(top:10),
              child: SizedBox(
                width: size.width,
                height: size.height*0.45,
                child:(_image != null)?
                Image.file(_image,fit: BoxFit.fill,)
                : (profile[0].profilePic == 'default') ?
                Image.asset("assets/default.jpg"):
                Image.network(
                  profile[0].profilePic,
                  fit:BoxFit.fill,
                ),
              ),
            ),
          ), 
        IconButton(
            padding: EdgeInsets.only(left:size.width*0.85,top:size.height*0.03),
            icon: Icon(Icons.camera_alt, color: Colors.amber,),
            iconSize: 40,
            onPressed: (){
              showChoiceDialog(context);
            },
          ),
      ],
    )
  );
}

Widget _buildUserName() {
  TextStyle _nameTextStyle = TextStyle(
    fontFamily: 'Roboto',
    color: Colors.black,
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
  );
  return Text(
    accountUser,
    style: _nameTextStyle,
  );
}

Widget _buildStatItem(String label, int count) {
  TextStyle _statLabelTextStyle = TextStyle(
    fontFamily: 'Roboto',
    color: Colors.black,
    fontSize: 16.0,
    fontWeight: FontWeight.w200,
  );
  TextStyle _statCountTextStyle = TextStyle(
    color: Colors.black54,
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
  );
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Text(
        count.toString(),
        style: _statCountTextStyle,
      ),
      Text(
        label,
        style: _statLabelTextStyle,
      ),
    ],
  );
}

Widget _buildStatContainer() {
  return Container(
    height: 80.0,
    margin: EdgeInsets.only(top: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _buildStatItem("Followers", profile[0].followers),
        _buildStatItem("Following", profile[0].following),
      ],
    ),
  );
}


Widget _talesButton() {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8,horizontal: 16.0),
    child: Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {},
          child: Container(
            height: 40.0,
            decoration: BoxDecoration(
              border: Border.all(),
              color: Color(0xFF404A5C),
            ),
            child: Center(
              child: RaisedButton(
                onPressed: (){
                  // setState(() {
                  //   // talesVisible = true;
                  // });
                },
                child: Text('Tales By You.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),),
                elevation: 0,
                color:Color(0xFF404A5C),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  save() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('loggedIn', 0);
  }

Widget _buildLogOut(Size size) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 0,horizontal: 16.0),
    child: Row(
      children: <Widget>[
        GestureDetector(
          onTap: () {},
          child: Container(
            height: 40.0,
            width: size.width *0.9,
            decoration: BoxDecoration(
              border: Border.all(),
              color: Colors.white,
            ),
            child:RaisedButton(
              onPressed: (){
                save();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              textColor: Color(0xFF404A5C),
              color:Colors.amber,
              elevation: 0,
              child:Text('Log Out')
              ),
          ),
        ),
      ],
    ),
  );
}

Widget _eachPostByYou(int index) {
  return Row(
    children: <Widget>[
      Text(
        personalTales[index].title, style: TextStyle(
          fontSize: 26,
          color: Colors.blueGrey
        )
      ),
      Spacer(),
      Text(
        personalTales[index].rate.toString() + "/10", style: TextStyle(
          fontSize: 18,
          color: Colors.black87
        )
      ),
      SizedBox(width: 10),
      _buildStatItem("Rates", personalTales[index].totalRates),
    ],
  );
}

@override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return FutureBuilder<dynamic>(
      future: _getRequest(),
      builder: (BuildContext context,  AsyncSnapshot<dynamic> snapshot) {
        // List<Widget> children;
        if(snapshot.hasData){
          return ListView(
          children:<Widget>[
            _buildprofileImage(size),
            SizedBox(height: 20),
            Center(child :_buildUserName(),),
            Center(child : Text(profile[0].place),),
            _buildStatContainer(),
            SizedBox(height: size.height*0.05,),
            _talesButton(),
            // // (talesVisible == true) 
            // // ?
            //  FutureBuilder(
            //     future: _getPersonalTales(),
            //     builder: (BuildContext context, AsyncSnapshot snapshot) {
            //       if(snapshot.hasData) {
                    // return 
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: personalTales.length,
                      itemBuilder: (context, index) {
                        return _eachPostByYou(index);
                      },
                    ),
                    
                  // else if(snapshot.hasError) {
                  //   return Center(
                  //     child: Text("An Error Occured!", style: TextStyle(fontSize: 16, color: Colors.redAccent)
                  //   ),);
                  // }
                  // else {
                  //   return Container();
                  // }
            //     }
            // ),
            // : Container(), 
            SizedBox(height: 20,),
            _buildLogOut(size),
          ],);
        }
        else if(snapshot.hasError){
          return
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            );
        }
        else {
          return 
            Center(
              child: CircularProgressIndicator(),
            );
        }
        
        // return ListView(
        //   children: children,
        // );
      }
      );
  }
}
