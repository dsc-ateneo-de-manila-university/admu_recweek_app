import 'package:admu_recweek_app/models/orgs.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:admu_recweek_app/screens/home.dart';
import 'package:admu_recweek_app/screens/list.dart';
import 'package:admu_recweek_app/screens/settings.dart';
import 'package:admu_recweek_app/screens/tracker.dart';
import 'package:admu_recweek_app/models/screen.dart';

// ignore: must_be_immutable
class MainScreen extends StatefulWidget {
  static GoogleSignIn _googleSignIn;
  static FirebaseUser _user;
  static List<Orgs> _orgList;
  static List<String> _strList;
  static List<Widget> _normalList;
  static List<Orgs> _copList = [];
  static List<Orgs> _groupList = [];

  MainScreen(
      [List<Orgs> orgList,
      List<String> normalList,
      List<Widget> strList,
      List<Orgs> copList,
      List<Orgs> groupList,
      FirebaseUser user,
      GoogleSignIn signIn]) {
    _user = user;
    _googleSignIn = signIn;
    _orgList = orgList;
    _strList = normalList;
    _normalList = strList;
    _copList = copList;
    _groupList = groupList;
  }

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static ScrollController scrollController;
  static TextEditingController _filter = new TextEditingController();

  var pages = [
    HomeScreen(MainScreen._copList, MainScreen._groupList, MainScreen._orgList,
        MainScreen._user),
    ListScreen(_filter, scrollController, MainScreen._user, MainScreen._orgList,
        MainScreen._strList, MainScreen._normalList),
    TrackerScreen(
      MainScreen._user,
      MainScreen._orgList,
      MainScreen._strList,
      MainScreen._normalList,
      MainScreen._copList,
      MainScreen._groupList,
    ),
    SettingsScreen(MainScreen._googleSignIn, MainScreen._user),
  ];

  // final dio = new Dio();
  String _searchText = "";
  List names = new List();
  List filteredNames = new List();
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text("Pavilion",
      style: TextStyle(
          color: const Color(0xff295EFF),
          fontWeight: FontWeight.bold,
          fontSize: 32.0));

  _MainScreenState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          filteredNames = names;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildBar(context),
        body: pages[selectedPageIndex],
        resizeToAvoidBottomPadding: false,
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                  title: Text(""),
                  backgroundColor: Colors.white,
                  icon: SizedBox(
                    width: 56.0,
                    height: 56.0,
                    child: selectedPageIndex == 0
                        ? Image(
                            image: AssetImage('assets/icons/home_active.png'))
                        : Image(image: AssetImage('assets/icons/home.png')),
                  )),
              BottomNavigationBarItem(
                  title: Text(""),
                  backgroundColor: Colors.white,
                  icon: SizedBox(
                    width: 56.0,
                    height: 56.0,
                    child: selectedPageIndex == 1
                        ? Image(
                            image: AssetImage('assets/icons/list_active.png'))
                        : Image(image: AssetImage('assets/icons/list.png')),
                  )),
              BottomNavigationBarItem(
                  title: Text(""),
                  backgroundColor: Colors.white,
                  icon: SizedBox(
                    width: 56.0,
                    height: 56.0,
                    child: selectedPageIndex == 2
                        ? Image(
                            image:
                                AssetImage('assets/icons/tracker_active.png'))
                        : Image(image: AssetImage('assets/icons/tracker.png')),
                  )),
              BottomNavigationBarItem(
                  title: Text(""),
                  backgroundColor: Colors.white,
                  icon: SizedBox(
                    width: 56.0,
                    height: 56.0,
                    child: selectedPageIndex == 3
                        ? Image(
                            image:
                                AssetImage('assets/icons/settings_active.png'))
                        : Image(image: AssetImage('assets/icons/settings.png')),
                  )),
            ],
            onTap: (index) {
              setState(() {
                selectedPageIndex = index;
              });
            },
            currentIndex: selectedPageIndex));
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      centerTitle: false,
      title: _appBarTitle,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0.05,
      iconTheme: new IconThemeData(color: const Color(0xff295EFF)),
      actions: <Widget>[
        Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SizedBox(
              height: 32.0,
              width: 32.0,
              child: IconButton(
                icon: _searchIcon,
                onPressed: _searchPressed,
              ),
            )),
      ],
    );
  }

  void _searchPressed() {
    setState(() {
      selectedPageIndex = 1;
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new Container(
          decoration: new BoxDecoration(
              color: const Color(0xffE2EAFF),
              borderRadius: new BorderRadius.circular(10.0)),
          child: new Center(
            child: new TextFormField(
              cursorColor: const Color(0xfff295EFF),
              controller: _filter,
              style: TextStyle(color: const Color(0xff8198BB)),
              decoration: new InputDecoration(
                border: InputBorder.none,
                focusColor: const Color(0xfff295EFF),
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                prefixIcon:
                    new Icon(Icons.search, color: const Color(0xff8198BB)),
              ),
            ),
          ),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text("Pavilion",
            style: TextStyle(
                color: const Color(0xff295EFF),
                fontWeight: FontWeight.bold,
                fontSize: 32.0));
        filteredNames = names;
        _filter.clear();
      }
    });
  }
}
