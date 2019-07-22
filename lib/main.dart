import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;
import 'dart:async';
//import 'package:google_sign_in/google_sign_in.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoogedIn = false;
  Map userProfile;
  final facebooklogin = FacebookLogin();

  void _login()async{
    final result = await facebooklogin.logInWithReadPermissions(["email"]);
    /*final result = await facebooklogin.logInWithReadPermissions(["email","public_profile"]).then((result){

    }).catchError((e){
      print(e);
    });*/

    switch(result.status){
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
        final profile = JSON.jsonDecode(graphResponse.body);
        final credential = FacebookAuthProvider.getCredential(
          accessToken: token
        );
        final firebaseUser = await FirebaseAuth.instance.signInWithCredential(credential);
        print(firebaseUser.displayName);
        print(profile);
        setState(() {
         userProfile=profile;
         _isLoogedIn=true; 
        });
        break;
      case FacebookLoginStatus.cancelledByUser:
        setState(() {
         _isLoogedIn=false; 
        });
        break;

      case FacebookLoginStatus.error:
        setState(() {
         _isLoogedIn=false; 
        });
        break;

    }
  }
  void _logout(){
    facebooklogin.logOut();
    setState(() {
     _isLoogedIn=false; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: _isLoogedIn
          ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //Image.network(userProfile['url'], height: 50.0,width:50.0),
              Text(userProfile["name"]),
               OutlineButton(
                  child: Text('Logout'),
                  onPressed: (){
                    _logout();
                  },
          ),
            ],
          )
         : OutlineButton(
              child: Text('Iniciar Sesión en Facebook'),
              onPressed: (){
                _login();
              },
          ),
        ),
      ),
    );
  }
}