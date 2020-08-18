import 'package:admu_recweek_app/models/orgs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:admu_recweek_app/templates/orgs.dart';
import 'package:admu_recweek_app/screens/bodies/sanggu.dart';

class GroupsScreen extends StatefulWidget {
  final String _title;
  final String _body;
  final List<Orgs> _orgs;
  final FirebaseUser _user;
  GroupsScreen(this._user, this._title, this._body, this._orgs);

  @override
  _GroupsScreenState createState() =>
      _GroupsScreenState(_user, _title, _body, _orgs);
}

class _GroupsScreenState extends State<GroupsScreen> {
  FirebaseUser _user;
  String _title;
  String _body;
  bool bookmark = false;
  List<Orgs> _orgs;

  _GroupsScreenState(this._user, this._title, this._body, this._orgs);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title,
          style: TextStyle(
              color: _body == "COA"
                  ? const Color(0xffE84C4C)
                  : _body == "LIONS"
                      ? const Color(0xffFF801D)
                      : const Color(0xff1C41B2),
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.05,
        iconTheme: new IconThemeData(
            color: _body == "COA"
                ? const Color(0xffE84C4C)
                : _body == "LIONS"
                    ? const Color(0xffFF801D)
                    : const Color(0xff1C41B2)),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.white,
        child: GridView.builder(
          itemCount: _orgs.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: (itemWidth / itemHeight), crossAxisCount: 2),
          itemBuilder: (BuildContext context, int index) {
            return new GestureDetector(
              onTap: () {
                if (_orgs[index].name ==
                    "Sanggunian ng mga Mag-aaral ng mga Paaralang Loyola ng Ateneo de Manila") {
                  return Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => new SangguScreen()));
                } else {
                  return Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => new OrgTemplateScreen(
                          _user,
                          _orgs[index].name,
                          _orgs[index].abbreviation,
                          _orgs[index].tagline,
                          _orgs[index].website,
                          _orgs[index].facebook,
                          _orgs[index].twitter,
                          _orgs[index].instagram,
                          _orgs[index].description,
                          _orgs[index].advocacy,
                          _orgs[index].core,
                          _orgs[index].projectTitleOne,
                          _orgs[index].projectDescOne,
                          _orgs[index].projectTitleTwo,
                          _orgs[index].projectDescTwo,
                          _orgs[index].projectTitleThree,
                          _orgs[index].projectDescThree,
                          _orgs[index].vision,
                          _orgs[index].mission,
                          _orgs[index].body,
                          _orgs[index].logo),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Image.asset(
                        _orgs[index].logo,
                        width: double.infinity,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            _orgs[index].abbreviation,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )),
                    ),
                    Text(
                      _orgs[index].description,
                      style: TextStyle(
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
