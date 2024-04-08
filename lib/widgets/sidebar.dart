import 'package:app_name/authentication/google_sign_in.dart';
import 'package:app_name/screens/analytics.dart';
import 'package:app_name/screens/brightness.dart';
import 'package:app_name/screens/community.dart';
import 'package:app_name/screens/home.dart';
import 'package:app_name/screens/landing.dart';
import 'package:app_name/screens/leaderboard.dart';
import 'package:app_name/screens/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  final String currentPage;

  const AppDrawer({Key? key, required this.currentPage}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final Map<String, IconData> _buttonIcons = {
    'Home': Icons.home_rounded,
    'Leaderboard': Icons.leaderboard_rounded,
    'Community': Icons.chat_rounded,
    'My Profile': Icons.person_2_rounded,
    'Analytics': Icons.analytics_rounded,
    'Brightness': Icons.brightness_1_rounded,
    'Logout': Icons.logout_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Color.fromARGB(255, 220, 64, 72),
              height: MediaQuery.of(context).size.height * 0.25,
              width: MediaQuery.of(context).size.width * 0.75,
              child: Image(
                image: const AssetImage("assets/design.png"),
              ),
            ),
            Column(
              children: [
                for (final buttonName in _buttonIcons.keys)
                  ListTile(
                    leading: Icon(
                      _buttonIcons[buttonName],
                      color: buttonName == widget.currentPage
                          ? Color.fromARGB(255, 230, 124, 129) // Highlight current page button
                          : Colors.black,
                    ),
                    title: Text(
                      buttonName,
                      style: TextStyle(
                        color: buttonName == widget.currentPage
                            ? Color.fromARGB(255, 230, 124, 129) // Highlight current page button
                            : Colors.black,
                      ),
                    ),
                    onTap: () async {
                      // Handle button tap here
                      // You can navigate to different pages or perform actions
                      Navigator.of(context)
                          .pop(); // Close the drawer before navigating

                      // Navigate to the corresponding page based on the button tapped
                      if (buttonName == 'Home') {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => home()),
                        );
                      } else if (buttonName == 'My Profile') {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => profile()),
                        );
                      } else if (buttonName == 'Leaderboard') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => leaderboard()),
                        );
                      } else if (buttonName == 'Community') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => community()),
                        );
                      } else if (buttonName == 'Analytics') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => AnalyticsPage()),
                        );
                      } else if (buttonName == 'Brightness') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => BrightnessAdjustmentScreen()),
                        );
                      } else if (buttonName == 'Logout') {
                        await FirebaseAuth.instance.signOut();
                        AuthService().signOutWithGoogle();
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const landing()),
                        );
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
