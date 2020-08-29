import 'package:admu_recweek_app/widgets/base-widget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:admu_recweek_app/screens/main.dart';
import 'package:admu_recweek_app/models/user.dart';
import 'package:admu_recweek_app/models/screen.dart';
import 'dart:convert';
import 'package:admu_recweek_app/models/orgs.dart';
import 'package:admu_recweek_app/templates/orgs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'bodies/coa.dart';
import 'bodies/lions.dart';
import 'bodies/sanggu.dart';
import 'package:page_transition/page_transition.dart';

class TrackerScreen extends StatefulWidget {
  final List<Orgs> orgList;
  final List<String> strList;
  final List<Widget> normalList;
  final FirebaseUser user;
  final List<Orgs> copList;
  final List<Orgs> groupList;
  final TextEditingController searchController;

  // ignore: non_constant_identifier_names
  TrackerScreen(
      [this.user,
      this.orgList,
      this.strList,
      this.normalList,
      this.copList,
      this.groupList,
      this.searchController]);

  @override
  _TrackerScreenState createState() => _TrackerScreenState(
      user, orgList, strList, normalList, copList, groupList, searchController);
}

class _TrackerScreenState extends State<TrackerScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final firestoreInstance = Firestore.instance;
  bool isUserSignedIn = false;
  bool maintenance = false;
  int contentState = 0;
  List<Orgs> orgList;
  List<String> strList;
  List<Widget> normalList;
  FirebaseUser user;
  List<String> bookmarkList = [];
  List<Widget> bookmarkWidgets = [];
  List<String> appliedList = [];
  List<Widget> appliedWidgets = [];
  List<Orgs> copList = [];
  List<Orgs> groupList = [];
  TextEditingController searchController;

  _TrackerScreenState(this.user, this.orgList, this.strList, this.normalList,
      this.copList, this.groupList, this.searchController);

  @override
  void initState() {
    contentState = 0;

    if (user != null) {
      checkIfUserIsSignedIn();
      firebaseReloader();
    }

    super.initState();
  }

  firebaseReloader() async {
    bookmarkList = [];
    bookmarkWidgets = [];
    orgList = [];
    appliedList = [];
    appliedWidgets = [];

    firestoreInstance
        .collection("bookmarks-2020-2021")
        .where("id", isEqualTo: user.uid)
        .getDocuments()
        .then((value) {
      value.documents.forEach((result) {
        bookmarkList.add(result.data['name']);
      });

      setState(() {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await loadJSON();
        });
      });
    });

    firestoreInstance
        .collection("applied-2020-2021")
        .where("id", isEqualTo: user.uid)
        .getDocuments()
        .then((value) {
      value.documents.forEach((result) {
        appliedList.add(result.data['name']);
      });
      setState(() {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await loadJSON();
        });
      });
    });
  }

  loadJSON() async {
    var orgResult;
    // Getting the file path of the JSON and Decoding the file into String
    String orgs = await rootBundle.loadString('assets/data/orgs.json');
    orgResult = json.decode(orgs.toString());
    orgList = [];

    for (int i = 0; i < orgResult.length; i++) {
      orgList.add(Orgs(
        orgResult[i]['Name'],
        orgResult[i]['Abbreviation'],
        orgResult[i]['Tagline'],
        orgResult[i]['Website'],
        orgResult[i]['Facebook'],
        orgResult[i]['Twitter'],
        orgResult[i]['Instagram'],
        orgResult[i]['Description'],
        orgResult[i]['Advocacy'],
        orgResult[i]['Core'],
        orgResult[i]['Awards'],
        orgResult[i]['projectTitleOne'],
        orgResult[i]['projectDescOne'],
        orgResult[i]['projectTitleTwo'],
        orgResult[i]['projectDescTwo'],
        orgResult[i]['projectTitleThree'],
        orgResult[i]['projectDescThree'],
        orgResult[i]['Vision'],
        orgResult[i]['Mission'],
        orgResult[i]['Body'],
        orgResult[i]['Logo'],
        orgResult[i]['Cluster'],
        orgResult[i]['Cover'],
        orgResult[i]['projectImageOne'],
        orgResult[i]['projectImageTwo'],
        orgResult[i]['projectImageThree'],
      ));
    }
    // Sorting Area
    orgList
        .sort((x, y) => x.name.toLowerCase().compareTo(y.name.toLowerCase()));

    filterBookmarks();
    filterApplied();
  }

  filterBookmarks() {
    List<Orgs> orgs = [];
    bookmarkWidgets = [];

    // We added all the userList to the users. for the passing/getting the specific value.
    orgs.addAll(orgList);

    // Loop
    orgs.forEach((org) {
      // Since, normalList is an WidgetArray = []
      // Here is the adding of Widget that depends on the lenght of the Array in  `users`

      bookmarkList.forEach((i) {
        if (i == org.name) {
          bookmarkWidgets.add(
            GestureDetector(
              onTap: () {
                if (org.abbreviation == "COA-M") {
                  return Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.leftToRight,
                          child: new COAScreen(user)));
                } else if (org.abbreviation == "LIONS") {
                  return Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.leftToRight,
                          child: new LionsScreen(user)));
                } else if (org.abbreviation == "Sanggu") {
                  return Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.leftToRight,
                          child: new SangguScreen(user)));
                } else {
                  return Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.leftToRight,
                          child: new OrgTemplateScreen(
                            user,
                            org.name,
                            org.abbreviation,
                            org.tagline,
                            org.website,
                            org.facebook,
                            org.twitter,
                            org.instagram,
                            org.description,
                            org.advocacy,
                            org.core,
                            org.projectTitleOne,
                            org.projectDescOne,
                            org.projectTitleTwo,
                            org.projectDescTwo,
                            org.projectTitleThree,
                            org.projectDescThree,
                            org.vision,
                            org.mission,
                            org.body,
                            org.logo,
                            org.cover,
                            org.projectImageOne,
                            org.projectImageTwo,
                            org.projectImageThree,
                          )));
                }
              },
              child: Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                secondaryActions: imageUrl == ""
                    ? null
                    : <Widget>[
                        IconSlideAction(
                            iconWidget: Image.asset('assets/icons/delete.png'),
                            onTap: () {
                              _removeBookmarks(
                                  org.name, org.abbreviation, org.body);
                            },
                            color: const Color(0xffE84C4C)),
                        IconSlideAction(
                            iconWidget: Image.asset('assets/icons/check.png'),
                            onTap: () {
                              _onApplied(org.name, org.abbreviation, org.body);
                            },
                            color: const Color(0xff7598FF))
                      ],
                child: ListTile(
                  leading: SizedBox(child: Image.asset(org.logo)),
                  title: Text(org.name),
                  subtitle: Text(org.body,
                      style: TextStyle(
                          fontSize: 12,
                          color: org.body == "COP"
                              ? const Color(0xff002864)
                              : org.body == "Student Groups"
                                  ? const Color(0xff1C41B2)
                                  : org.body == "LIONS"
                                      ? const Color(0xffFF801D)
                                      : const Color(0xffE84C4C))),
                ),
              ),
            ),
          );
        }
      });
    });

    // SetState to change the Value every time is triggers
    setState(() {
      // ignore: unnecessary_statements
      bookmarkWidgets;
    });
  }

  filterApplied() {
    List<Orgs> orgs = [];
    appliedWidgets = [];

    // We added all the userList to the users. for the passing/getting the specific value.
    orgs.addAll(orgList);

    // Loop
    orgs.forEach((org) {
      // Since, normalList is an WidgetArray = []
      // Here is the adding of Widget that depends on the lenght of the Array in  `users`

      appliedList.forEach((i) {
        if (i == org.name) {
          appliedWidgets.add(
            GestureDetector(
                onTap: () {
                  if (org.abbreviation == "COA-M") {
                    return Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.leftToRight,
                            child: new COAScreen(user)));
                  } else if (org.abbreviation == "LIONS") {
                    return Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.leftToRight,
                            child: new LionsScreen(user)));
                  } else if (org.abbreviation == "Sanggu") {
                    return Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.leftToRight,
                            child: new SangguScreen(user)));
                  } else {
                    return Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.leftToRight,
                          child: new OrgTemplateScreen(
                            user,
                            org.name,
                            org.abbreviation,
                            org.tagline,
                            org.website,
                            org.facebook,
                            org.twitter,
                            org.instagram,
                            org.description,
                            org.advocacy,
                            org.core,
                            org.projectTitleOne,
                            org.projectDescOne,
                            org.projectTitleTwo,
                            org.projectDescTwo,
                            org.projectTitleThree,
                            org.projectDescThree,
                            org.vision,
                            org.mission,
                            org.body,
                            org.logo,
                            org.cover,
                            org.projectImageOne,
                            org.projectImageTwo,
                            org.projectImageThree,
                          )),
                    );
                  }
                },
                child: Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  secondaryActions: <Widget>[
                    IconSlideAction(
                        iconWidget: Image.asset('assets/icons/delete.png'),
                        onTap: () {
                          _removeApplied(org.name, org.abbreviation, org.body);
                        },
                        color: const Color(0xffE84C4C)),
                  ],
                  child: ListTile(
                    leading: SizedBox(child: Image.asset(org.logo)),
                    title: Text(org.name),
                    subtitle: Text(org.body,
                        style: TextStyle(
                            fontSize: 12,
                            color: org.body == "COP"
                                ? const Color(0xff002864)
                                : org.body == "Student Groups"
                                    ? const Color(0xff1C41B2)
                                    : org.body == "LIONS"
                                        ? const Color(0xffFF801D)
                                        : const Color(0xffE84C4C))),
                  ),
                )),
          );
        }
      });
    });

    // SetState to change the Value every time is triggers
    setState(() {
      // ignore: unnecessary_statements
      appliedWidgets;
    });
  }

  void checkIfUserIsSignedIn() async {
    var userSignedIn = await _googleSignIn.isSignedIn();

    setState(() {
      isUserSignedIn = userSignedIn;
    });
  }

  Future<FirebaseUser> _handleSignIn() async {
    FirebaseUser user;
    bool userSignedIn = await _googleSignIn.isSignedIn();

    setState(() {
      isUserSignedIn = userSignedIn;
    });

    if (isUserSignedIn) {
      user = await _auth.currentUser();
    } else {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      user = (await _auth.signInWithCredential(credential)).user;
      userSignedIn = await _googleSignIn.isSignedIn();
      setState(() {
        isUserSignedIn = userSignedIn;
      });
    }

    getCurrentUser(user);
    return user;
  }

  void onGoogleSignIn(BuildContext context) async {
    FirebaseUser user = await _handleSignIn();
    var userSignedIn = await Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: MainScreen(orgList, normalList, strList, copList, groupList,
              user, _googleSignIn),
        ));

    setState(() {
      isUserSignedIn = userSignedIn == null ? true : false;
    });
  }

  void _removeBookmarks(name, abbreviation, body) async {
    if (name == "League of Independent Organizations") {
      firestoreInstance
          .collection("bookmarks-2020-2021")
          .document('${user.uid}-LIONS')
          .delete()
          .then((_) {
        Fluttertoast.showToast(
            msg: "You have remove LIONS in your bookmark list",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            firebaseReloader();
          });
        });
      });
    } else if (name == "Council of Organizations of the Ateneo - Manila") {
      firestoreInstance
          .collection("bookmarks-2020-2021")
          .document('${user.uid}-COA')
          .delete()
          .then((_) {
        Fluttertoast.showToast(
            msg: "You have remove COA-M in your bookmark list",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            firebaseReloader();
          });
        });
      });
    } else if (name ==
        "Sanggunian ng mga Mag-aaral ng mga Paaralang Loyola ng Ateneo de Manila") {
      firestoreInstance
          .collection("bookmarks-2020-2021")
          .document('${user.uid}-Sanggu')
          .delete()
          .then((_) {
        Fluttertoast.showToast(
            msg: "You have remove Sanggu in your bookmark list",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            firebaseReloader();
          });
        });
      });
    } else {
      firestoreInstance
          .collection("bookmarks-2020-2021")
          .document('${user.uid}-$name')
          .delete()
          .then((_) {
        Fluttertoast.showToast(
            msg: "You have remove $name in your bookmark list",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            firebaseReloader();
          });
        });
      });
    }
  }

  void _removeApplied(name, abbreviation, body) async {
    if (name == "League of Independent Organizations") {
      firestoreInstance
          .collection("applied-2020-2021")
          .document('${user.uid}-LIONS')
          .delete()
          .then((_) {
        firestoreInstance
            .collection("bookmarks-2020-2021")
            .document('${user.uid}-LIONS')
            .setData({
          "id": user.uid,
          "name": name,
          "abbreviation": abbreviation,
          "body": body,
          "bookmark": true,
        }).then((_) {
          Fluttertoast.showToast(
              msg: "You removed LIONS in your applied list",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey,
              textColor: Colors.white,
              fontSize: 16.0);
        });
        setState(() {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            firebaseReloader();
          });
        });
      });
    } else if (name == "Council of Organizations of the Ateneo - Manila") {
      firestoreInstance
          .collection("applied-2020-2021")
          .document('${user.uid}-COA')
          .delete()
          .then((_) {
        firestoreInstance
            .collection("bookmarks-2020-2021")
            .document('${user.uid}-COA')
            .setData({
          "id": user.uid,
          "name": name,
          "abbreviation": abbreviation,
          "body": body,
          "bookmark": true,
        }).then((_) {
          Fluttertoast.showToast(
              msg: "You removed COA-M in your applied list",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey,
              textColor: Colors.white,
              fontSize: 16.0);
        });
        setState(() {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            firebaseReloader();
          });
        });
      });
    } else if (name ==
        "Sanggunian ng mga Mag-aaral ng mga Paaralang Loyola ng Ateneo de Manila") {
      firestoreInstance
          .collection("applied-2020-2021")
          .document('${user.uid}-Sanggu')
          .delete()
          .then((_) {
        firestoreInstance
            .collection("bookmarks-2020-2021")
            .document('${user.uid}-Sanggu')
            .setData({
          "id": user.uid,
          "name": name,
          "abbreviation": abbreviation,
          "body": body,
          "bookmark": true,
        }).then((_) {
          Fluttertoast.showToast(
              msg: "You removed Sanggu in your applied list",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey,
              textColor: Colors.white,
              fontSize: 16.0);
        });
        setState(() {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            firebaseReloader();
          });
        });
      });
    } else {
      firestoreInstance
          .collection("applied-2020-2021")
          .document('${user.uid}-$name')
          .delete()
          .then((_) {
        firestoreInstance
            .collection("bookmarks-2020-2021")
            .document('${user.uid}-$name')
            .setData({
          "id": user.uid,
          "name": name,
          "abbreviation": abbreviation,
          "body": body,
          "bookmark": true,
        }).then((_) {
          Fluttertoast.showToast(
              msg: "You removed $name in your applied list",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey,
              textColor: Colors.white,
              fontSize: 16.0);
        });
        setState(() {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            firebaseReloader();
          });
        });
      });
    }
  }

  void _onApplied(
    name,
    abbreviation,
    body,
  ) async {
    if (name == "League of Independent Organizations") {
      firestoreInstance
          .collection("applied-2020-2021")
          .document('${user.uid}-LIONS')
          .setData({
        "id": user.uid,
        "name": name,
        "abbreviation": abbreviation,
        "body": body,
        "applied": true,
      }).then((_) {
        firestoreInstance
            .collection("bookmarks-2020-2021")
            .document('${user.uid}-LIONS')
            .delete()
            .then((_) {
          Fluttertoast.showToast(
              msg: "You have applied in LIONS",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey,
              textColor: Colors.white,
              fontSize: 16.0);
        });
        setState(() {
          firebaseReloader();
        });
      });
    } else if (name == "Council of Organizations of the Ateneo - Manila") {
      firestoreInstance
          .collection("applied-2020-2021")
          .document('${user.uid}-COA')
          .setData({
        "id": user.uid,
        "name": name,
        "abbreviation": abbreviation,
        "body": body,
        "applied": true,
      }).then((_) {
        firestoreInstance
            .collection("bookmarks-2020-2021")
            .document('${user.uid}-COA')
            .delete()
            .then((_) {
          Fluttertoast.showToast(
              msg: "You have applied in COA-M",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey,
              textColor: Colors.white,
              fontSize: 16.0);
        });
        setState(() {
          firebaseReloader();
        });
      });
    } else if (name ==
        "Sanggunian ng mga Mag-aaral ng mga Paaralang Loyola ng Ateneo de Manila") {
      firestoreInstance
          .collection("applied-2020-2021")
          .document('${user.uid}-Sanggu')
          .setData({
        "id": user.uid,
        "name": name,
        "abbreviation": abbreviation,
        "body": body,
        "applied": true,
      }).then((_) {
        firestoreInstance
            .collection("bookmarks-2020-2021")
            .document('${user.uid}-Sanggu')
            .delete()
            .then((_) {
          Fluttertoast.showToast(
              msg: "You have applied in Sanggu",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey,
              textColor: Colors.white,
              fontSize: 16.0);
        });
        setState(() {
          firebaseReloader();
        });
      });
    } else {
      firestoreInstance
          .collection("applied-2020-2021")
          .document('${user.uid}-$name')
          .setData({
        "id": user.uid,
        "name": name,
        "abbreviation": abbreviation,
        "body": body,
        "applied": true,
      }).then((_) {
        firestoreInstance
            .collection("bookmarks-2020-2021")
            .document('${user.uid}-$name')
            .delete()
            .then((_) {
          Fluttertoast.showToast(
              msg: "You have applied in $name",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey,
              textColor: Colors.white,
              fontSize: 16.0);
        });
        setState(() {
          firebaseReloader();
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(builder: (context, sizeInfo) {
      return Container(
          color: Colors.white,
          padding: imageUrl == "" || maintenance
              ? const EdgeInsets.symmetric(vertical: 30, horizontal: 60)
              : null,
          child: imageUrl == ""
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                      Text("Sorry for the Inconvenience",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: const Color(0xff295EFF),
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      Container(
                          padding: EdgeInsets.symmetric(vertical: 13),
                          child: Image.asset('assets/images/maintenance.png')),
                      Text(
                          "You either do not have internet connection or you signed in as guest. Please try again by signing in with Google",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xff000000),
                            fontSize: 13,
                          ))
                    ])
              : maintenance
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                          Text("This page is under maintenance...",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: const Color(0xff295EFF),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                          Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child:
                                  Image.asset('assets/images/maintenance.png')),
                          Text("Coming soon!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: const Color(0xff295EFF),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold))
                        ])
                  : Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 30.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new GestureDetector(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 24.0, horizontal: 8.0),
                                  decoration: BoxDecoration(
                                    color: contentState == 0
                                        ? const Color.fromRGBO(
                                            41, 94, 255, 0.15)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        child: Image.asset(
                                          'assets/icons/saved.png',
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              5,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: AutoSizeText(
                                          "Saved",
                                          minFontSize: 20,
                                          maxFontSize: 24,
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: const Color(0xff295EFF),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    contentState = 0;
                                  });
                                },
                              ),
                              new GestureDetector(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 24.0, horizontal: 8.0),
                                  decoration: BoxDecoration(
                                    color: contentState == 1
                                        ? const Color.fromRGBO(
                                            41, 94, 255, 0.15)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        child: Image.asset(
                                          'assets/icons/applied.png',
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              5,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: AutoSizeText(
                                          "Applied",
                                          minFontSize: 20,
                                          maxFontSize: 24,
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: const Color(0xff295EFF),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    contentState = 1;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: contentState == 0
                              ? _savedScreen(context)
                              : _appliedScreen(context),
                        )
                      ],
                    ));
    });
  }

  Widget _savedScreen(BuildContext context) {
    if (bookmarkWidgets.length == 0) {
      return new Container(
          margin: const EdgeInsets.symmetric(vertical: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                child: Container(
                  child: Image.asset('assets/images/saved_empty.png'),
                  padding: const EdgeInsets.only(bottom: 12.0),
                ),
              ),
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'You haven’t saved any org!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                    ),
                  ),
                  FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      onPressed: () {
                        onGoogleSignIn(context);
                        selectedPageIndex = 1;
                      },
                      color: const Color(0xff295EFF),
                      child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Find an organization',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold))))
                ],
              )
            ],
          ));
    } else {
      return new ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          itemCount: bookmarkWidgets.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return bookmarkWidgets[index];
          });
    }
  }

  Widget _appliedScreen(BuildContext context) {
    if (appliedWidgets.length == 0) {
      return new Container(
          margin: const EdgeInsets.symmetric(vertical: 30.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Container(
                    child: Image.asset('assets/images/applied_empty.png'),
                    padding: const EdgeInsets.only(bottom: 12.0),
                  ),
                ),
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'You haven’t applied for any org!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16.0, color: Colors.black),
                      ),
                    ),
                    FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        onPressed: () {
                          setState(() {
                            contentState = 0;
                          });
                        },
                        color: const Color(0xff295EFF),
                        child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Update my tracker',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold))))
                  ],
                )
              ]));
    } else {
      return new ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          itemCount: appliedWidgets.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return appliedWidgets[index];
          });
    }
  }
}
