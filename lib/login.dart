// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'App.dart';
import 'jsonLogin.dart';
import 'jsonSignUp.dart';

//Login Page
String user;
class Login extends StatefulWidget {
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  var loginInfo = new List<jsonLogin>();
  var signupInfo = new List<jsonSignUp>();
//Key for the Login Form
  final _logInForm = GlobalKey<FormState>();

//Key for the sign up form
  final _signUpForm = GlobalKey<FormState>();

//Login and SignUp Info
  String _user;
  String _password;
  String _emailId;
  String _confirmedpassword;
  String _place;

//Toggle Between LogIn and SignUp forms
  bool _signUpVisibility = false;
  bool _logInVisibility = true;

//Failure Action
  int check = 0;
  bool _failure = false;
  
//Get Data from URL                    
  Future getJsonData (String loginurl) async {
    var response = await http.get(
      Uri.encodeFull(loginurl),
      headers: {"Accept": "application/json"}
    );
    return response;
  }

  var data;

//Save data to memory
  Future save() async{
    final SharedPreferences prefs =  await SharedPreferences.getInstance();
    await prefs.setInt('loggedIn', 1);
    await prefs.setString('accountUser', _user);
    return;
  }

//Returns the brand logo
  Widget _logo() {
    return Center(
              child: Image.asset('assets/logo.png',
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width*0.7,
              ),
            );
  }

//UserName Input
  Widget _userName() {
    return Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 50,
            child: TextFormField(
              onSaved: (value) => _user = value,
              validator: (value) {
                if(value.isEmpty) {
                  return "Username is Compulsory.";
                }
                return null;
              },
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Username',
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
                prefixIcon: Icon(Icons.person, color: Colors.amberAccent,),
              ),
            ),
          );
  }

//Email Input For Sign Up
  Widget _email() {
    return Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 50,
          child: TextFormField(
            onSaved: (value) => _emailId = value,
            validator: (value) {
              if(value.isEmpty) {
                return "Email is Compulsory.";
              }
              return null;
            },
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Your Email Id',
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
                prefixIcon: Icon(Icons.alternate_email,  color: Colors.amberAccent,),
            ),
          ),
        );
  }

//Place Input For Sign Up
  Widget _yourPlace() {
    return Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 50,
          child: TextFormField(
            onSaved: (value) => _place = value,
            validator: (value) {
              if(value.isEmpty) {
                return "Place is Compulsory.";
              }
              return null;
            },
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Your City/Town',
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
                prefixIcon: Icon(Icons.place, color: Colors.amberAccent,),
            ),
          ),
        );
  }

//Password Input
  Widget _passWord() {
    return Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 50,
            child: TextFormField(
              onSaved: (value) => _password = value,
              obscureText: true,
              validator: (value) {
                if(value.isEmpty) {
                  return "Password is Compulsory";
                }
                return null;
              },
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Password',
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
                prefixIcon: Icon(Icons.lock, color: Colors.amberAccent,),
              ),
            ),
          );
  }

//Confirm Password Input For Sign Up
  Widget _confirmPassword() {
    return Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 50,
            child: TextFormField(
              onSaved: (value) => _confirmedpassword = value,
              validator: (value) {
                if(value.isEmpty) {
                  return "Please Confirm Your Password.";
                }
                return null;
              },
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Confirm Password.',
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
                prefixIcon: Icon(Icons.lock, color: Colors.amberAccent,),
              ),
            ),
          );
  }

  String _message = "";

   getObjects(data)  {
     data.then((response) {
        setState(() {
          Iterable list = json.decode(response.body);
          loginInfo = list.map((model) => jsonLogin.fromJson(model)).toList();
          print("25");
        });
      });
      // Future.delayed(Duration(seconds: 2)); 
      return loginInfo;
  }


  var s;
  _manageLogIn() {
    final form = _logInForm.currentState;
    form.save();
    if(form.validate()) {
      var loginurl ="https://i8ghj2hqua.execute-api.ap-south-1.amazonaws.com/prod/login?username="+_user;
      data = getJsonData(loginurl);
        s = getObjects(data); 
           
      Future.delayed(Duration(seconds: 2)); 
        // setState(() {
        //   _message = "Click to Confirm";
        //   _failure = true;
        // });
        if( loginInfo.length == 1 ) {
          print("7");
          if( loginInfo[0].password == _password ) {
            print("8");
            save();
            print("9");
            print(_user);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => App(_user)),
            );
          } else {
              setState(() {
                _message = "Wrong Credentials";
                _failure = true;
              });
          }
      } else {
          setState(() {
            _message = "Click to Confirm.";
            _failure = true;
          });
        }
  } 
  }


  Future _manageSignUp() async {
    final form = _signUpForm.currentState;
    form.save();  
    if(form.validate()) {


      if( _password == _confirmedpassword ) {
                        
        var signURL = "https://i8ghj2hqua.execute-api.ap-south-1.amazonaws.com/prod/signup?username="+_user+"&password="+_password+"&email="+_emailId+"&place="+_place;
        var data = getJsonData(signURL);
        s =  data.then((response) {
          setState(() {
            Iterable list = json.decode(response.body);
            signupInfo = list.map((model) => jsonSignUp.fromJson(model)).toList();
          });
        });

        if( signupInfo.length == 1 ) {
          if( signupInfo[0].response == 1 ) {
            save();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => App(_user)),
            );
          } else {
              setState(() {
                _message = "Try a different Username.";
                _failure = true;
              });
            }
          } else {
              setState(() {
                _message = "Click Again To Confirm.";
                _failure = true;
              });
          }
      }
      else {
        setState(() {
          _message = "Wrong Credentials.";
          _failure = true;
        });
      }
    }
  }
  

//Submit Form
  Widget _submitLogIn(double fontSize,int alpha,double width,double height) {
    return SizedBox(
          width: width,
          height: height,
          child: RaisedButton(
              onPressed: (){
                _manageLogIn();    
              },
              color: Color.fromARGB(alpha, 0, 0, 0),
              textColor: Colors.white,
              splashColor: Colors.blueGrey,
              child: Text("Log In", style: TextStyle(fontSize: fontSize),),
            ),
    );
  }

//Submit SignUp Form
  Widget _submitSignUp(double fontSize,int alpha,double width,double height) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
            width: width,
            height: height,
            child: RaisedButton(
                onPressed: (){
                  _manageSignUp();
                },
                color: Color.fromARGB(alpha, 0, 0, 0),
                textColor: Colors.white,
                splashColor: Colors.blueGrey,
                child: Text("Sign Up", style: TextStyle(fontSize: fontSize),),
              
              ),
        ),
      );
  }

//Change Form
  Widget _changeForm(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
            width: 80,
            height: 30,
            child: RaisedButton(
                onPressed: (){
                  setState(() {
                    _logInVisibility = !_logInVisibility;
                    _signUpVisibility = !_signUpVisibility;
                  });
                },
                color: Color.fromARGB(110, 0, 0, 0),
                textColor: Colors.white,
                splashColor: Colors.blueGrey,
                child: Text(text, style: TextStyle(fontSize: 12),),
              ),
      ),
    );
  }

//Login Form
  Widget _formLogIn() {
    return Visibility(
      visible: _logInVisibility,
          child: Form(
          key: _logInForm,
          child: Column(
            children: <Widget>[
              _userName(),
              SizedBox(
                height: 10,
              ),
              _passWord(),
              SizedBox(
                height: 30,
              ),
              (_failure)? Text( _message ) : Container(),
              _submitLogIn(14, 150, 110, 35),
              SizedBox(
                height:30,
              ),
              Text("Don't have an account?", style: TextStyle(fontSize: 10)),
              _changeForm("Sign Up"),
            ],
          ),
        ),
    );
  }

// Form Sign Up
  Widget _formSignUp() {
    return Visibility(
      visible: _signUpVisibility,
      child: Form(
        key: _signUpForm,
          child: Column(
            children: <Widget>[
              _userName(),
              SizedBox(
                height: 8,
              ),
              _email(),
              SizedBox(
                height: 8,
              ),
              _yourPlace(),
              SizedBox(
                height: 8
              ),
              _passWord(),
              SizedBox(
                height: 8,
              ),
              _confirmPassword(),
              SizedBox(
                height: 20,
              ),
              (_failure)? Text(_message) : Container(),
              _submitSignUp(14, 150, 110, 35),
              SizedBox(
                height:10,
              ),
              Text("Already own an account?", style: TextStyle(fontSize: 10,)),
              _changeForm("Log In"),
            ],
          ), 
        ),
      );
  }

//Build
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          
          children: <Widget>[
            SizedBox(
              height:60,
            ),

            _logo(),
            _formLogIn(),
            _formSignUp(),
          ],
        ),
      ),
    );
  }


}