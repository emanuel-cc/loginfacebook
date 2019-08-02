import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:google_sign_in/google_sign_in.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLogged = false;
  FirebaseUser myUser;

 Future<FirebaseUser> _loginWithFacebook() async {
    var facebookLogin = new FacebookLogin();
    var result = await facebookLogin.logInWithReadPermissions(['email']);

    final token = result.accessToken.token;

    debugPrint(result.status.toString());

    if (result.status == FacebookLoginStatus.loggedIn) {
      final AuthCredential credential = FacebookAuthProvider.getCredential(accessToken: token );
      FirebaseUser user =
          await _auth.signInWithCredential(credential);
      return user;
    }
    return null;
  }

  void _logOut()async{
    await _auth.signOut().then((onValue){
      setState(() {
        
      });
      isLogged=false;
    });
  }

  void _logIn(){
    _loginWithFacebook().then((response){
      if(response != null){
        myUser = response;
        isLogged=true;
        setState(() {
          
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: isLogged
          ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //Image.network(userProfile['url'], height: 50.0,width:50.0),
              //Text(firebaseUser.displayName),
              Image.network(myUser.photoUrl),
              Text(myUser.displayName),
               OutlineButton(
                  child: Text('Logout'),
                  onPressed: (){
                    _logOut();
                  },
          ),
            ],
          )
         : OutlineButton(
              child: Text('Iniciar Sesión en Facebook'),
              onPressed: (){
                _logIn();
              },
          ),
        ),
      ),
    );
  }
}