

import 'package:app_name/authentication/cloud_firestore_methods.dart';
import 'package:app_name/authentication/user_details_model.dart';
import 'package:app_name/authentication/user_details_provider.dart';
import 'package:app_name/constants/utils.dart';
import 'package:app_name/screens/analytics.dart';
import 'package:app_name/screens/home.dart';
import 'package:app_name/screens/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

int old_score = 0;
int add_score = 0;
bool isLast = false;
class ThreeImageButtonScreen extends StatefulWidget {
  final String language;
  final String location;
  final int NoOfImage;
  final String chapNo;

  const ThreeImageButtonScreen({
    super.key,
    required this.language,
    required this.location,
    required this.NoOfImage,
    required this.chapNo,
  });

  @override
  _ThreeImageButtonScreenState createState() => _ThreeImageButtonScreenState();
}

class _ThreeImageButtonScreenState extends State<ThreeImageButtonScreen> {
  String img1 = "";
  String img2 = "";
  CloudFirestoreClass cloudFirestoreClass = CloudFirestoreClass();

  void initState() {
    fetchAndSortLeaderboard();
    CloudFirestoreClass().getNameAndAddress();
    super.initState();

    // Lock the screen orientation to landscape modes
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> updateScoreAndLocationInRecord(
      String userId,
      String chapterId,
      int newScore,
      String newLocation,
      String NoOfImage,
      ) async {
    final firestore = FirebaseFirestore.instance;

    try {
      int scoreDifference = 0;
      // Retrieve the user's data outside the transaction
      final chapterDocRef = firestore.collection('record').doc(chapterId + "_" + userId);
      final userRef = firestore.collection('users').doc(userId);
      final analyticsRef = firestore.collection('analytics').doc(chapterId + "_" + NoOfImage);
      final [userDocSnapshot, userInUsersCollectionSnapshot, analyticsSnapshot] = await Future.wait([
        chapterDocRef.get(),
        userRef.get(),
        analyticsRef.get(),
      ]);
      await firestore.runTransaction((transaction) async {
        final userInUsersCollectionData = userInUsersCollectionSnapshot.data() as Map<String, dynamic>;

        // Update the user's total score (Score) in the users collection
        final int totalScore = userInUsersCollectionData['Score'] ?? 0;
        final analyticsData = analyticsSnapshot.data() as Map<String, dynamic>;

        // Update the user's total score (Score) in the users collection
        int correct = analyticsData['correct'] ?? 0;
        int incorrect = analyticsData['incorrect'] ?? 0;
        // User's document exists, update the score and location
        //final userData = userDocSnapshot.data() as Map<String, dynamic>;
        //final int currentScore = userData['score'] ?? 0;
        if (newScore > 0) {
          correct = correct + 1;
        } else {
          incorrect = incorrect + 1;
        }
        scoreDifference = newScore;
        if (!userDocSnapshot.exists) {
          // If the user's document does not exist, create it with the specified ID
          transaction.set(chapterDocRef, {
            'score': newScore,
            'location': newLocation,
          });
        } else {


          transaction.update(chapterDocRef, {
            'score': newScore,
            'location': newLocation,
          });
        }
        if (!analyticsSnapshot.exists) {
          // If the user's document does not exist, create it with the specified ID
          transaction.set(analyticsRef, {
            'correct': correct,
            'incorrect': incorrect,
          });
        } else {


          transaction.update(analyticsRef, {
            'correct': correct,
            'incorrect': incorrect,
          });
        }
          transaction.update(userRef, {
            'Score': totalScore + scoreDifference,
          });
      });
    } catch (e) {
      print("Error updating score and location: $e");
    }
  }





  Future<void> fetchAndSortLeaderboard() async {
    final DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .doc(widget.location)
        .get();

    setState(() {
      if (docSnapshot.exists && docSnapshot.data() != null) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

        if (data.containsKey('${widget.language}1') &&
            data.containsKey('${widget.language}2')) {
          img1 = data[widget.language + '1'];
          img2 = data[widget.language + '2'];
        } else {
          // Handle the case where the field does not exist
        }
      } else {
        // Handle the case where the document does not exist or data is null
      }
    });
  }
  Future<void> fetchScore(String new_location) async {
    final DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .doc(new_location)
        .get();

    setState(() {
      if (docSnapshot.exists && docSnapshot.data() != null) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        if (data.containsKey('score')) {
          add_score = data['score'];
        } else {
          // Handle the case where the field does not exist
        }
        if (data.containsKey('last')) {
          isLast = data['last'] == true;
        } else {
          // Handle the case where 'last' field is not present
          isLast = false; // or set it to your desired default value
        }
      }
    });
  }



  @override
  void dispose() {
    // Don't forget to unlock the orientation when you leave this screen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<UserDetailsProvider>(context).getData();
    UserDetailsModel userDetails =
        Provider.of<UserDetailsProvider>(context).userDetails;
    Size screenSize = Utils().getScreenSize();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Button 1
            ElevatedButton(
              onPressed: () async {
                // Add your action for Button 1 here
                String new_location = widget.location + "/image" +
                    (widget.NoOfImage + 1).toString() + '/1';
                await fetchScore(new_location);

                old_score = userDetails.score;

                if (isLast == false) {
                  await updateScoreAndLocationInRecord(FirebaseAuth.instance.currentUser!.uid, widget.chapNo, add_score, new_location, (widget.NoOfImage).toString());
                  showScoreDialog(context, widget.language, new_location, widget.NoOfImage+1, widget.chapNo);
                } else {
                  await updateScoreAndLocationInRecord(FirebaseAuth.instance.currentUser!.uid, widget.chapNo, add_score, "Completed", (widget.NoOfImage).toString());
                  showFinalDialog(context, widget.language, new_location, widget.NoOfImage+1, widget.chapNo);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: CircleBorder(),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Conditional check to display CircularProgressIndicator while loading
                  if (img1.isEmpty)
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    )
                  else
                    Image.network(
                      img1,
                      fit: BoxFit.cover,
                      width: screenSize.width * 0.15,
                      height: screenSize.width * 0.15,
                    ),
                ],
              ),
            ),

            // Button 2
            ElevatedButton(
              onPressed: () async {
                // Add your action for Button 1 here
                String new_location = widget.location + "/image" +
                    (widget.NoOfImage + 1).toString() + '/2';
                await fetchScore(new_location);

                old_score = userDetails.score;
                // Update the user's profile with the new score
                if (isLast == false) {
                  await updateScoreAndLocationInRecord(FirebaseAuth.instance.currentUser!.uid, widget.chapNo, add_score, new_location, (widget.NoOfImage).toString());
                  showScoreDialog(context, widget.language, new_location, widget.NoOfImage+1, widget.chapNo);
                } else {
                  await updateScoreAndLocationInRecord(FirebaseAuth.instance.currentUser!.uid, widget.chapNo, add_score, "Completed", (widget.NoOfImage).toString());
                  showFinalDialog(context, widget.language, new_location, widget.NoOfImage+1, widget.chapNo);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: CircleBorder(),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Conditional check to display CircularProgressIndicator while loading
                  if (img2.isEmpty)
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    )
                  else
                    Image.network(
                      img2,
                      fit: BoxFit.cover,
                      width: screenSize.width * 0.15,
                      height: screenSize.width * 0.15,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showScoreDialog(BuildContext context, String lang, String loc, int imag, String chapNo) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
              backgroundColor: Color.fromARGB(255, 230, 124, 129),
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                      "Old Stars: "+ old_score.toString()
                  ),
                  SizedBox(height: 16.0),
                  Text(
                      "New Stars: " + add_score.toString()
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    "Total Stars: " + (old_score+add_score).toString()
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 220, 64, 72), // Change the text color here
                        ),
                        onPressed: () {
                          // Implement your action for the first button here.
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                home(),
                            ),
                          );
                        },
                        child: Text('Home',
                            style: TextStyle(
                              color: Colors.white,
                            )),
                      ),
                      SizedBox(width: 16.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 220, 64, 72), // Change the text color here
                        ),
                        onPressed: () {
                          // Implement your action for the second button here.
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                VideoPlayerScreen(language: lang, location: loc, NoOfImage: imag, chapNo: chapNo,),
                            ),
                          );
                        },
                        child: Text('Continue',
                            style: TextStyle(
                              color: Colors.white,
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
  );
}

void showFinalDialog(BuildContext context, String lang, String loc, int imag, String chapNo) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
            backgroundColor: Color.fromARGB(255, 230, 124, 129),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                    "Old Stars: "+ old_score.toString()
                ),
                SizedBox(height: 16.0),
                Text(
                    "New Stars: " + add_score.toString()
                ),
                SizedBox(height: 16.0),
                Text(
                    "Total Stars: " + (old_score+add_score).toString()
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 220, 64, 72), // Change the text color here
                      ),
                      onPressed: () {
                        // Implement your action for the first button here.
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              home(),
                          ),
                        );
                      },
                      child: Text('Completed',
                          style: TextStyle(
                            color: Colors.white,
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
