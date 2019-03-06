import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailedScreen extends StatelessWidget {
  final UserInfoDetails detailsUser;
  DetailedScreen({Key key, @required this.detailsUser}) : super(key: key);
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {

    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.subscribeToTopic(detailsUser.uid);
    
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Notification list'),
        automaticallyImplyLeading: false,
        leading: new IconButton(
          icon: new Icon(Icons.list, color: Colors.white),
            onPressed: () {
              _scaffoldKey.currentState.openDrawer();
            }
        ),
      ),
      key: _scaffoldKey,
      drawer: new Drawer(
        child: new ListView(
          children: <Widget> [
            // new ListTile(
            //   title: new Text('Remove notification data'),
            //   onTap: () {
            //     _removeNotificationData().then((a){
            //       setState();
            //     });
            //   },
            // ),
            new ListTile(
              title: new Text('Logout'),
              onTap: () {
                _firebaseMessaging.unsubscribeFromTopic(detailsUser.uid);
                _removeAllData();
                final FirebaseAuth _fAuth = FirebaseAuth.instance;
                _fAuth.signOut();
                Navigator.pushReplacement(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => new MyApp(),
                  ),
                );
              },
            ),
          ],
        )
      ),
 
      body: NotificationList(),
    );
  }

  void setState() {}
}

class NotificationList extends StatefulWidget {
  @override
  _NotificationList createState() => new _NotificationList();
}

class _NotificationList extends State<NotificationList> {
  List<String> _notifications = <String>[];

  @override
  void initState() {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on launch $message');
        String dataMessage = message['aps']['alert'];
        _saveNotification(dataMessage);
        setState(() {
          _notifications.insert(0, dataMessage);
        });
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
        String dataMessage = message['aps']['alert'];
        _saveNotification(dataMessage);
        setState(() {
          _notifications.insert(0, dataMessage);
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
        String dataMessage = message['aps']['alert'];
        _saveNotification(dataMessage);
        setState(() {
          _notifications.insert(0, dataMessage);
        });
      },
    );

    _getNotificationList().then((list) {
      setState(() {
        if (list != null)
        {
          _notifications.addAll(list);
          _notifications = _notifications.reversed.toList();
        }
      });
    });
  }

  Widget _buildRow(String pair) {
    return new ListTile(
      title: new Text(
        pair,
        textAlign:TextAlign.center
      ),
    );
  }

  Widget _buildNotiList()
  {
    return new ListView.builder(
      itemCount: _notifications.length,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (BuildContext _context, int i) {
        final int index = i;
        return _buildRow(_notifications[index]);
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildNotiList();
  }

}

Future<List<String>> _getNotificationList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> list = prefs.getStringList("NotiList");
  return list;
}

_saveNotification(String notificationText) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> list = prefs.getStringList("NotiList");

  if (list == null)
  {
    list = new List<String>();
  }

  list.add(notificationText);
  await prefs.setStringList('NotiList', list);
}

Future<void> _removeAllData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

Future<void> _removeNotificationData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('NotiList');
}