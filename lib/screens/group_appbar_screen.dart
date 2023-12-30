import 'package:app_name/screens/chat_screen.dart';
import 'package:app_name/screens/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupDetailsScreen extends StatelessWidget {
  final String groupName;
  final String imageUrl;
  final Map<String, dynamic>
      participants; // Map of user IDs and their designations
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  GroupDetailsScreen({
    required this.groupName,
    required this.imageUrl,
    required this.participants,
  });

  Future<List<Map<String, dynamic>>> getMemberDetails() async {
    List<Map<String, dynamic>> admins = [];
    List<Map<String, dynamic>> members = [];

    for (String userId in participants.keys) {
      final userDoc = await firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>;
      final userName = userData['name'] as String;
      final profilePic = userData['avatar location'] as String;
      final designation = participants[userId] as String;
      final tag = userData['tag'] as String;

      final memberData = {
        'userId': userId,
        'name': userName,
        'designation': designation,
        'avatar location': profilePic,
        'tag': tag,
      };

      if (designation == 'admin') {
        admins.add(memberData);
      } else {
        members.add(memberData);
      }
    }

    // Sort members by name (case-insensitive)
    admins.sort(
        (a, b) => a['name'].toLowerCase().compareTo(b['name'].toLowerCase()));
    members.sort(
        (a, b) => a['name'].toLowerCase().compareTo(b['name'].toLowerCase()));

    return [...admins, ...members];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF075E54),
        title: Text(
          'Group Info',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Implement more options menu
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: getMemberDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final List<Map<String, dynamic>> memberDetails =
              snapshot.data as List<Map<String, dynamic>>;

          return ListView(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  // Ensure the CircleAvatar has a transparent background
                  child: imageUrl == "No Image"
                      ? Icon(Icons.camera_alt_rounded,
                          size: 35.0) // Replace Icon with your preferred icon
                      : FadeInImage(
                          placeholder:
                              AssetImage('path_to_placeholder_image.png'),
                          // Replace with a placeholder image
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                ),
                title: Text(
                  groupName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${participants.length} Members',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              Divider(),
              ListTile(
                title: Text(
                  'Admins',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Column(
                children: memberDetails
                    .where((member) => member['designation'] == 'admin')
                    .map((member) {
                  final userId = member['userId'];
                  final userName = member['name'];
                  final profilePic = member['avatar location'];
                  final tag = member['tag'];

                  return ListTile(
                      leading: ClipOval(
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white,
                          child: profilePic != null
                              ? Image.asset(
                                  profilePic,
                                  fit: BoxFit.cover, // or other BoxFit values
                                )
                              : Text(
                                  userName[0],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      title: Text(userName),
                      subtitle: Text('Admin'),
                      // You can add actions for admins here
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OneOnOneChatScreen(
                                      otherUserId: userId,
                                      currentUserId: FirebaseAuth
                                          .instance.currentUser!.uid,
                                      otherUserName: userName,
                                      otherUserAvatar: profilePic,
                                      otherUserTag: tag,
                                    )));
                      });
                }).toList(),
              ),
              Divider(),
              ListTile(
                title: Text(
                  'Members',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Column(
                children: memberDetails
                    .where((member) => member['designation'] != 'admin')
                    .map((member) {
                  final userId = member['userId'];
                  final userName = member['name'];
                  final profilePic = member['avatar location'];
                  final tag = member['tag'];

                  return ListTile(
                      leading: ClipOval(
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white,
                          child: profilePic != null
                              ? Image.asset(
                                  profilePic,
                                  fit: BoxFit.cover, // or other BoxFit values
                                )
                              : Text(
                                  userName[0],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      title: Text(userName),
                      subtitle: Text('Member'),
                      // You can add actions for members here
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OneOnOneChatScreen(
                                      otherUserId: userId,
                                      currentUserId: FirebaseAuth
                                          .instance.currentUser!.uid,
                                      otherUserName: userName,
                                      otherUserAvatar: profilePic,
                                      otherUserTag: tag,
                                    )));
                      });
                }).toList(),
              ),
              // Add more group information or actions as needed
            ],
          );
        },
      ),
    );
  }
}

class OneDetailsScreen extends StatelessWidget {
  final String name;
  final String avatar;
  final String tag;
  final String id;

  OneDetailsScreen({
    required this.name,
    required this.avatar,
    required this.tag,
    required this.id,
  });

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF075E54),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 50.0),
            ClipOval(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Image.asset(
                  avatar,
                  fit: BoxFit.cover, // or other BoxFit values
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              name, // Replace with the name
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              FirebaseAuth.instance.currentUser != null
                  ? (FirebaseAuth.instance.currentUser!.email ?? FirebaseAuth.instance.currentUser!.phoneNumber) ?? 'N/A'
                  : 'N/A', // Replace 'N/A' with the default text you want to display
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              tag, // Replace with the tag
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
