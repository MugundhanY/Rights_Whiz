import 'package:app_name/constants/utils.dart';
import 'package:app_name/screens/login.dart';
import 'package:flutter/material.dart';

class landing extends StatefulWidget {
  const landing({super.key});

  @override
  State<landing> createState() => _landingState();
}

class _landingState extends State<landing> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = Utils().getScreenSize();
    return Scaffold(
      body: Stack(
        children: [
          Container(
            child: SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: screenSize.height * 0.05),
                      Image.asset(
                        "assets/Rights_Whiz.png",
                        fit: BoxFit.cover, // or other BoxFit values
                        width: 900,
                      ),

                      // sign in button

                      SizedBox(height: screenSize.height * 0.0626),

                      // not a member? register now
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => login()));
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black, backgroundColor: Color.fromARGB(255, 244, 205, 206), // Change the text color here
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                          ),
                          minimumSize: Size(screenSize.width*0.125, screenSize.height*0.02), // Set the desired size here
                        ),
                        child: Text("Play"),
                      ),
                      SizedBox(height: screenSize.height * 0.0626),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
