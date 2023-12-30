import 'dart:io';

import 'package:app_name/authentication/cloud_firestore_methods.dart';
import 'package:app_name/authentication/google_sign_in.dart';
import 'package:app_name/authentication/user_details_provider.dart';
import 'package:app_name/constants/utils.dart';
import 'package:app_name/screens/landing.dart';
import 'package:app_name/screens/video_player.dart';
import 'package:app_name/widgets/sidebar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../authentication/user_details_model.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  final String currentPage = 'Home';

  @override
  void initState() {
    super.initState();
    CloudFirestoreClass().getNameAndAddress();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit an App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                //<-- SEE HERE
                child: const Text('No',
                    style: TextStyle(
                      color: Colors.red,
                    )),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => exit(0),
                    ),
                  );
                },
                child: const Text('Yes',
                    style: TextStyle(
                      color: Colors.green,
                    )),
              ),
            ],
          ),
        )) ??
        false;
  }

  Widget build(BuildContext context) {
    Provider.of<UserDetailsProvider>(context).getData();
    UserDetailsModel userDetails =
        Provider.of<UserDetailsProvider>(context).userDetails;
    Size screenSize = Utils().getScreenSize();
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        drawer: AppDrawer(currentPage: currentPage),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 220, 64, 72),
          centerTitle: true,
          title: Image.asset(
            "assets/home_screen_logo_white.png",
            fit: BoxFit.cover, // or other BoxFit values
            width: 900,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          /*leading: InkWell(
          onTap: () {},
          child: const Icon(
            Icons.subject,
            color: Colors.white,
          ),
        ),

         */
          actions: [
            InkWell(
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.notifications,
                  size: 20,
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(110.0),
            child: Container(
              padding: const EdgeInsets.only(left: 30, bottom: 20),
              child: Row(
                children: [
                  ClipOval(
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Image.asset(
                        userDetails.avatar,
                        fit: BoxFit.cover, // or other BoxFit values
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ' + userDetails.name,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20.0,
                              ),
                              SizedBox(width: 4.0),
                              Text(
                                userDetails.score.toString(),
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Image.asset(
              'assets/game_image.png',
              width: double.infinity,
              // Stretch the image horizontally to fill the screen
              height: double.infinity,
              // Stretch the image vertically to fill the screen
              fit: BoxFit.fill, // Use BoxFit.fill to fill the entire screen
            ),
            Positioned(
              bottom: 105.0, // Adjust the bottom position as needed
              left: 158.0, // Adjust the left position as needed
              child: MaterialButton(
                minWidth: 25,
                height: 20,
                color: Color.fromARGB(255, 220, 64, 72),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(
                        language: '${userDetails.language}',
                        location: 'video/chap1',
                        NoOfImage: 0,
                        chapNo: "chap1",
                      ),
                    ),
                  );
                },
                child: const Text(
                  "1",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Positioned(
              bottom: 275.0, // Adjust the bottom position as needed
              left: 222.0, // Adjust the left position as needed
              child: MaterialButton(
                minWidth: 25,
                height: 20,
                color: Color.fromARGB(255, 220, 64, 72),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(
                        language: '${userDetails.language}',
                        location: 'video/chap2',
                        NoOfImage: 0,
                        chapNo: "chap2",
                      ),
                    ),
                  );
                },
                child: const Text(
                  "2",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
