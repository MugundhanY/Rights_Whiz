import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';



class NewGroupScreen extends StatefulWidget {
  @override
  _NewGroupScreenState createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  TextEditingController groupNameController = TextEditingController();
  List<String> selectedUserIds = []; // Store selected user IDs here

  // Reference to the Firestore collection for users
  final CollectionReference userCollection = FirebaseFirestore.instance
      .collection('users');

  // Reference to the Firestore collection for chats
  final CollectionReference chatCollection = FirebaseFirestore.instance
      .collection('chats');
  String searchQuery = ''; // Store the search query
  File? groupNameAvatar; // Declare groupNameAvatar as a File
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<void> _selectGroupAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        groupNameAvatar = File(pickedFile.path); // Assign the selected image
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Group'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              // Create the group in Firebase Firestore
              final groupId = await createGroup(
                  groupNameController.text, selectedUserIds, groupNameAvatar);
              if (groupId != null) {
                // Navigate back to the chat or group list screen
                Navigator.pop(context);
              } else {
                // Handle error if group creation fails
                // You can display a snackbar or show an error message
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          ListTile(
            leading: GestureDetector(
              onTap: () {
                _selectGroupAvatar();
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 28,
                backgroundImage: groupNameAvatar != null
                    ? FileImage(
                    groupNameAvatar!) // Use the selected image if available
                    : null,
                child: groupNameAvatar != null
                    ? null // Use the selected image if available
                    : Icon(Icons
                    .add_a_photo_rounded), // If no image is selected, set this to null or a placeholder image
                // Display a placeholder or selected group image here
              ),
            ),
            title: TextField(
              controller: groupNameController,
              decoration: InputDecoration(
                hintText: 'Group Name',
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.search),
            title: TextField(
              onChanged: (query) {
                // Update the searchQuery when the text field changes
                setState(() {
                  searchQuery = query.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search users to add to the group',
              ),
            ),
          ),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: userCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No users available.'));
                  }

                  // Get the user documents
                  final users = snapshot.data!.docs;

                  final currentUserId = firebaseAuth.currentUser!.uid;
                  // Filter and sort users based on the search query
                  final filteredAndSortedUsers = users.where((user) {
                    final userName = user['name'].toString().toLowerCase();
                    return userName.contains(searchQuery);
                  }).toList();

                  // Sort the filtered users by name in a case-insensitive manner
                  filteredAndSortedUsers.sort((a, b) {
                    final nameA = a['name'].toString().toLowerCase();
                    final nameB = b['name'].toString().toLowerCase();
                    return nameA.compareTo(nameB);
                  });

                  // Get the ID of the current user (replace 'currentUserId' with the actual ID)

                  return ListView.builder(
                    itemCount: filteredAndSortedUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredAndSortedUsers[index];
                      final userId = user.id;

                      // Skip rendering the current user
                      if (userId == currentUserId) {
                        return Container(); // Skip rendering
                      }

                      final userName = user['name'];
                      final profilePicUrl = user['avatar location'];
                      final isSelected = selectedUserIds.contains(userId);

                      return Column(
                        children: [
                          ListTile(
                            onTap: () {
                              // Toggle user selection when tapped
                              setState(() {
                                if (isSelected) {
                                  selectedUserIds.remove(userId);
                                } else {
                                  selectedUserIds.add(userId);
                                }
                              });
                            },
                            leading: ClipOval(
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.white,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(
                                      profilePicUrl,
                                      fit: BoxFit
                                          .cover, // or other BoxFit values
                                    ),
                                    if (isSelected) // Display tick mark if selected
                                      Icon(
                                        Icons.check,
                                        color: Colors.green,
                                        size: 32,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            title: Text(userName),
                            trailing: Checkbox(
                              value: isSelected,
                              onChanged: (bool? value) {
                                if (value != null) {
                                  setState(() {
                                    if (value) {
                                      selectedUserIds.add(userId);
                                    } else {
                                      selectedUserIds.remove(userId);
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                          Divider(), // Add space between list elements
                        ],
                      );
                    },
                  );
                },
              )
          ),
        ],
      ),
    );
  }

  // Function to create a new group in Firestore
  Future<String?> createGroup(
      String groupName, List<String> memberIds, File? groupImage) async {
    try {
      // Create a new document in the "chats" collection
      final newGroupDocRef = chatCollection.doc();

      // Create a map of participants with their roles
      final participants = <String, String>{};
      for (final memberId in memberIds) {
        participants[memberId] = 'member'; // You can use 'member' or 'admin' roles
      }

      // Add the creator (current user) as an admin
      final currentUserId = firebaseAuth.currentUser!.uid;
      participants[currentUserId] = 'admin';

      // Upload the group image to Firebase Storage (if available)
      String? imageUrl;
      if (groupImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child('group_images/${newGroupDocRef.id}.jpg');
        final uploadTask = storageRef.putFile(groupImage);
        await uploadTask.whenComplete(() async {
          imageUrl = await storageRef.getDownloadURL();
        });
      }

      // Set the data for the new group, including participants, group name, and group image URL
      await newGroupDocRef.set({
        'participants': participants,
        'type': 'group',
        'groupName': groupName,
        'groupImageUrl': imageUrl==null? "No Image": imageUrl, // Add the group image URL
        'lastMessage': {
          'text': 'Created the group', // Initialize with an empty message
          'sender': currentUserId, // Initialize with an empty sender
          'timestamp': FieldValue.serverTimestamp(),
        },
      });

      // Return the ID of the newly created group
      return newGroupDocRef.id;
    } catch (e) {
      // Handle any errors here (e.g., Firebase exceptions)
      print('Error creating group: $e');
      return null; // Return null to indicate failure
    }
  }

}
