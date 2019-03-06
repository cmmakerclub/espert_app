import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'DetailedScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Espert',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: const Text('Espert app'),
        ),
        body: new HomeScreen()
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: new Container(
        child: new Column(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          // mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: new Column(
                children: <Widget>[
                  FacebookScreen(),
                ],
              ),
              flex: 1,
            ),
            Expanded(
              child: Container(
                child: FormLogin(),
              ),
              flex: 2,
            ),
          ]
        )
      )

    );
    
  }
}

class FacebookScreen extends StatefulWidget {
  @override
  _FacebookScreen createState() => new _FacebookScreen();
}

class _FacebookScreen extends State<FacebookScreen>  {

  Future<FirebaseUser> _signIn(BuildContext context) async {

    var token = await _getFacebookAccessToken();
    AuthCredential credential;

    //print(token);

    if (token == 'null' || token == "" || token == null)
    {
      final facebookLogin = FacebookLogin();
      final result = await facebookLogin.logInWithReadPermissions(['email']);

      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          // _showInSnackBar(context, "login");
          // _sendTokenToServer(result.accessToken.token);
          // _showLoggedInUI();
          break;
        case FacebookLoginStatus.cancelledByUser:
          // _showInSnackBar(context, "cancel");
          // _showCancelledMessage();
          break;
        case FacebookLoginStatus.error:
          // _showInSnackBar(context, "result.errorMessage");
          // _showErrorOnUI(result.errorMessage);
          break;
      }

      print("login finish");
      credential = FacebookAuthProvider.getCredential(
        accessToken: result.accessToken.token,
      );
      _setFacebookAccessToken(result.accessToken.token);
    }
    else 
    {
      credential = FacebookAuthProvider.getCredential(
        accessToken: token,
      );

      print("no need to login");
    }

    final FirebaseAuth _fAuth = FirebaseAuth.instance;

    FirebaseUser user = await _fAuth.signInWithCredential(credential);
    //Token: ${accessToken.token}

    ProviderDetails userInfo = new ProviderDetails(
        user.providerId, user.uid, user.displayName, user.photoUrl, user.email);

    List<ProviderDetails> providerData = new List<ProviderDetails>();
    providerData.add(userInfo);

    UserInfoDetails userInfoDetails = new UserInfoDetails(
        user.providerId,
        user.uid,
        user.displayName,
        user.photoUrl,
        user.email,
        user.isAnonymous,
        user.isEmailVerified,
        providerData);

    _saveUser(userInfoDetails);

    Navigator.pushReplacement(
      context,
      new MaterialPageRoute(
        builder: (context) => new DetailedScreen(detailsUser: userInfoDetails),
      ),
    );

    return user;
  }

  @override
  void initState() {
    _getFacebookAccessToken().then((token) {
      if (token != 'null' && token != "" && token != null)
      {
        _signIn(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var materialButton = new MaterialButton(
          textColor: Colors.white,
          padding: new EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
          minWidth: 180.0,
          onPressed: () => _signIn(context)
            .then((FirebaseUser user) => print(user))
            .catchError((e) => print(e)),
          child: new Text('Sign in with Facebook'),
          color: Colors.lightBlueAccent,
        );
    return
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
          children: [
            new Container(
            margin: const EdgeInsets.only(top: 80.0),
            alignment: FractionalOffset.center,
            child:
              materialButton,
            ),
          ]
      );
  }
}

class FormLogin extends StatefulWidget {
  @override
  _FormLoginState createState() => _FormLoginState();
}

class _FormLoginState extends State<FormLogin> {

  String username = "";
  String password = "";

  Future<FirebaseUser> _signUp(BuildContext context) async {
    FirebaseUser user;

    try {
      final FirebaseAuth _fAuth = FirebaseAuth.instance;
      user = await _fAuth.createUserWithEmailAndPassword(email: username, password: password);
      await _signIn(context);

    }
    catch(e) {
      _showDialog(context, e.toString());
    }
    return user;
  }

  Future<FirebaseUser> _signIn(BuildContext context) async {

    final FirebaseAuth _fAuth = FirebaseAuth.instance;
    FirebaseUser user;
    try {
      user = await _fAuth.signInWithEmailAndPassword(email: username, password: password);
    }
    catch(e) {
      _showDialog(context, e.toString());
    }

    ProviderDetails userInfo = new ProviderDetails(
        user.providerId, user.uid, user.displayName, user.photoUrl, user.email);

    List<ProviderDetails> providerData = new List<ProviderDetails>();
    providerData.add(userInfo);

    UserInfoDetails userInfoDetails = new UserInfoDetails(
        user.providerId,
        user.uid,
        user.displayName,
        user.photoUrl,
        user.email,
        user.isAnonymous,
        user.isEmailVerified,
        providerData);

    _saveUser(userInfoDetails);

    Navigator.pushReplacement(
      context,
      new MaterialPageRoute(
        builder: (context) => new DetailedScreen(detailsUser: userInfoDetails),
      ),
    );
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: new Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: TextField(
                obscureText: false,
                autocorrect: false, // turns off auto-correct
                decoration: InputDecoration(
                  labelText: "Username",
                  // hintText: 'Enter text; return submits',
                ),
                onChanged: (str) {
                  username = str;
                },
                onSubmitted: (str) {
                  username = str;
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: new Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: TextField(
                obscureText: true,
                autocorrect: false, // turns off auto-correct
                decoration: InputDecoration(
                  labelText: "Password",
                  // hintText: 'Enter text; return submits',
                ),
                onChanged: (str) {
                  password = str;
                },
                onSubmitted: (str) {
                  password = str;
                },
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new MaterialButton(
                  onPressed: () => _signIn(context).then((FirebaseUser user) => print(user))
                    .catchError((e) => print(e)),
                  textColor: Colors.white,
                  padding: new EdgeInsets.all(8.0),
                  minWidth: 100.0,
                  child: new Text('Sign in'),
                  color: Colors.lightBlueAccent,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new MaterialButton(
                  onPressed: () => _signUp(context),
                  textColor: Colors.white,
                  padding: new EdgeInsets.all(8.0),
                  minWidth: 100.0,
                  child: new Text('Sign up'),
                  color: Colors.lightBlueAccent,
                ),
              ),              
            ],
          ) 
        ],
      )
    );
  }
}

Future<String> _getFacebookAccessToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String facebookAccessToken = prefs.getString('facebookAccessToken');
  return facebookAccessToken;
}

_setFacebookAccessToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // print(token);
  await prefs.setString('facebookAccessToken', token); 
}

_getUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String providerId = prefs.getString('user.providerId');
  String uid = prefs.getString('user.uid');
  String displayName = prefs.getString('user.displayName');
  String photoUrl = prefs.getString('user.photoUrl');
  String email = prefs.getString('user.email');
  bool isAnonymous = prefs.getBool('user.isAnonymous');
  bool isEmailVerified = prefs.getBool('user.isEmailVerified');

  UserInfoDetails userInfoDetails = 
    new UserInfoDetails(providerId,
                        uid,
                        displayName,
                        photoUrl,
                        email,
                        isAnonymous,
                        isEmailVerified,
                        null);
  return userInfoDetails;
}

_saveUser(UserInfoDetails userDetail) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.setString('user.providerId', userDetail.providerId);
  await prefs.setString('user.uid', userDetail.uid);
  await prefs.setString('user.displayName', userDetail.displayName);
  await prefs.setString('user.photoUrl', userDetail.photoUrl);
  await prefs.setString('user.email', userDetail.email);
  await prefs.setBool('user.isAnonymous', userDetail.isAnonymous);
  await prefs.setBool('user.isEmailVerified', userDetail.isEmailVerified);

}

// / Displays text in a snackbar
_showInSnackBar(BuildContext context, String text) {
  Scaffold.of(context).showSnackBar(SnackBar(
    backgroundColor: Colors.blue,
    content: Text(text),
  ));
}

// user defined function
_showDialog(BuildContext context, String text) {
  // flutter defined function
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        content: new Text(text),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new FlatButton(
            child: new Text("Close"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class UserInfoDetails {
  UserInfoDetails(this.providerId, this.uid, this.displayName, this.photoUrl,
      this.email, this.isAnonymous, this.isEmailVerified, this.providerData);

  /// The provider identifier.
  final String providerId;

  /// The provider’s user ID for the user.
  final String uid;

  /// The name of the user.
  final String displayName;

  /// The URL of the user’s profile photo.
  final String photoUrl;

  /// The user’s email address.
  final String email;

  // Check anonymous
  final bool isAnonymous;

  //Check if email is verified
  final bool isEmailVerified;

  //Provider Data
  final List<ProviderDetails> providerData;
}

class ProviderDetails {
  final String providerId;

  final String uid;

  final String displayName;

  final String photoUrl;

  final String email;

  ProviderDetails(
      this.providerId, this.uid, this.displayName, this.photoUrl, this.email);
}