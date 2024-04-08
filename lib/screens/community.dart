import 'package:app_name/authentication/user_details_model.dart';
import 'package:app_name/authentication/user_details_provider.dart';
import 'package:app_name/constants/color.dart';
import 'package:app_name/screens/chat_screen.dart';
import 'package:app_name/screens/create_group.dart';
import 'package:app_name/screens/home.dart';
import 'package:app_name/widgets/sidebar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Color accentColor = Color(0xFF25D366);

class community extends StatelessWidget {
  final String currentPage = 'Community';
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        drawer: AppDrawer(currentPage: currentPage),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 220, 64, 72),
          title: Text('Community'),
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
                // Implement menu options
              },
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white, // Change the indicator color here
            labelColor: Colors.white, // Change the label text color here
            tabs: [
              Tab(text: 'One-on-One'), // First tab for One-on-One chats
              Tab(text: 'Groups'), // Second tab for Group chats
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ChatListOne(currentUserId: firebaseAuth.currentUser!.uid),
            ChatList(
                currentUserId: firebaseAuth.currentUser!.uid,
                chatType: 'group'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => UserListScreen()),
            );
          },
          backgroundColor: Color.fromARGB(255, 220, 64, 72),
          child: Icon(Icons.chat),
        ),
      ),
    );
  }
}

class ChatListOne extends StatelessWidget {
  final String currentUserId;

  ChatListOne({required this.currentUserId});

  Future<String> getSenderName(String senderId) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(senderId)
        .get();
    final userData = userDoc.data() as Map<String, dynamic>;
    return userData['name'] as String;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('type', isEqualTo: "one_on_one")
          .orderBy('lastMessage.timestamp', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final chats = snapshot.data?.docs ?? [];


        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (BuildContext context, int index) {
            final chat = chats[index];
            final data = chat.data() as Map<String, dynamic>;

            final lastMessage = data['lastMessage'] as Map<String, dynamic>;
            final lastMessageText = lastMessage['text'] as String?;
            final timestamp = lastMessage['timestamp'] as Timestamp?;
            final senderId = lastMessage['sender'] as String;
            final participants = data['participants'] as List<dynamic>;
            final userStatus = participants.contains(currentUserId) ? 'participant' : null;
            if (userStatus == null) {
              // Skip rendering this chat if the user is not a participant
              return SizedBox.shrink();
            }
            return FutureBuilder(
              future: getSenderName(senderId),
              builder: (BuildContext context,
                  AsyncSnapshot<String> senderNameSnapshot) {
                if (senderNameSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (senderNameSnapshot.hasError) {
                  return Text('Error: ${senderNameSnapshot.error}');
                }

                final senderName = senderNameSnapshot.data;

                return ChatListItemOne(
                  lastMessageText: lastMessageText ?? '', // Provide an empty string as a fallback
                  senderName: senderName ?? '', // Provide an empty string as a fallback
                  timestamp: timestamp,
                  currentUserId: currentUserId,
                  chatId: chat.id ?? '', // Provide an empty string as a fallback
                  participants: data['participants'] ?? [], // Provide an empty list as a fallback
                );

              },
            );
          },
        );
      },
    );
  }
}

class ChatList extends StatelessWidget {
  final String currentUserId;
  final String chatType;

  ChatList({required this.currentUserId, required this.chatType});

  Future<String> getSenderName(String senderId) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(senderId)
        .get();
    final userData = userDoc.data() as Map<String, dynamic>;
    return userData['name'] as String;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('type', isEqualTo: chatType)
          .orderBy('lastMessage.timestamp', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final chats = snapshot.data?.docs ?? [];

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (BuildContext context, int index) {
            final chat = chats[index];
            final data = chat.data() as Map<String, dynamic>;

            final lastMessage = data['lastMessage'] as Map<String, dynamic>;
            final lastMessageText = lastMessage['text'] as String?;
            final timestamp = lastMessage['timestamp'] as Timestamp?;
            final senderId = lastMessage['sender'] as String;

            final participants = data['participants'] as Map<String, dynamic>;

            // Check if the current user is a participant in this chat
            final userStatus = participants[currentUserId] as String?;
            if (userStatus == null) {
              // Skip rendering this chat if the user is not a participant
              return SizedBox.shrink();
            }

            return FutureBuilder(
              future: getSenderName(senderId),
              builder: (BuildContext context,
                  AsyncSnapshot<String> senderNameSnapshot) {
                if (senderNameSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (senderNameSnapshot.hasError) {
                  return Text('Error: ${senderNameSnapshot.error}');
                }

                final senderName = senderNameSnapshot.data;

                // Provide fallback values for empty or null senderName and lastMessageText
                final displaySenderName = senderName;
                String displayLastMessageText;

                if (displaySenderName == 'Unknown User' && lastMessageText == null) {
                  displayLastMessageText = 'Group has been created';
                } else {
                  displayLastMessageText = lastMessageText ?? '';
                }

                return ChatListItem(
                  chatName: data['groupName'] as String,
                  // Use 'groupName' for group chats
                  lastMessageText: displayLastMessageText,
                  senderName: displaySenderName,
                  // Include sender's name
                  timestamp: timestamp,
                  imageUrl: data['groupImageUrl'] as String,
                  // Use 'groupImageUrl' for group chats
                  currentUserId: currentUserId,
                  chatType: chatType,
                  chatId: chat.id,
                  participants: participants,
                );
              },
            );
          },
        );
      },
    );
  }
}

class ChatListItemOne extends StatelessWidget {
  final String? lastMessageText;
  final String? senderName;
  final Timestamp? timestamp;
  final String currentUserId;
  final String chatId;
  final List<dynamic> participants;

  ChatListItemOne({
    required this.lastMessageText,
    required this.senderName,
    required this.timestamp,
    required this.currentUserId,
    required this.chatId,
    required this.participants,
  });

  Future<Map<String, dynamic>?> getOtherUserData() async {
    String otherUserId = participants[0] == currentUserId? participants[1]: participants[0];

    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserId)
          .get();

      if (userSnapshot.exists) {
        return userSnapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching other user data: $e');
    }

    return null; // Return null in case of an error or if the user doesn't exist
  }

  @override
  Widget build(BuildContext context) {
    String formattedTimestamp = '';
    String otherUserId = participants[0] == currentUserId? participants[1]: participants[0];
    if (timestamp != null) {
      final dateTime = timestamp!.toDate();
      final timeFormatter = DateFormat.jm();
      formattedTimestamp = timeFormatter.format(dateTime);
    }

    return FutureBuilder(
        future: getOtherUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // You can show a loading indicator while fetching data
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return ListTile(
              // Display a placeholder when there's an error or no data
              title: Text('Unknown User'),
              subtitle: Text('No Data Available'),
            );
          }

          Map<String, dynamic> userData = snapshot.data!;

          return ListTile(
            leading: ClipOval(
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Image.asset(
                  userData['avatar location'],
                  fit: BoxFit.cover, // or other BoxFit values
                ),
              ),
            ),
            title: Text(userData['name']),
            subtitle: currentUserId == otherUserId
                ? lastMessageText!.contains(
                        "https://firebasestorage.googleapis.com/v0/b/game-42ced.appspot.com/o/chat_images")
                    ? Container(
                        child: Row(
                          children: [
                            Text("You: "),
                            Icon(Icons.photo),
                            Text("Photo"),
                          ],
                        ),
                      )
                    : Text("You: ${lastMessageText}" ?? "")
                : lastMessageText!.contains(
                        "https://firebasestorage.googleapis.com/v0/b/game-42ced.appspot.com/o/chat_images")
                    ? Container(
                        child: Row(
                          children: [
                            Text("${senderName}: "),
                            Icon(Icons.photo),
                            Text("Photo"),
                          ],
                        ),
                      )
                    : Text("${senderName}: ${lastMessageText}" ?? ""),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formattedTimestamp),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            onTap: () {
              // Implement chat opening functionality

              Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OneOnOneChatScreen(
                otherUserId: participants[0] == currentUserId? participants[1]: participants[0], // Pass the chatId to the chat screen
                currentUserId: currentUserId,
                otherUserTag: userData['tag'],
                otherUserAvatar: userData['avatar location'],
                otherUserName: userData['name'],
              ),
            ),
          );
            },
          );
        });
  }
}

class ChatListItem extends StatelessWidget {
  final String chatName;
  final String? lastMessageText;
  final String? senderName; // Add senderName parameter
  final Timestamp? timestamp;
  final String imageUrl;
  final String currentUserId;
  final String chatType;
  final String chatId;
  final Map<String, dynamic> participants;

  ChatListItem({
    required this.chatName,
    required this.lastMessageText,
    required this.senderName, // Include senderName parameter
    required this.timestamp,
    required this.imageUrl,
    required this.currentUserId,
    required this.chatType,
    required this.chatId,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    String formattedTimestamp = '';
    Provider.of<UserDetailsProvider>(context).getData();
    UserDetailsModel userDetails =
        Provider.of<UserDetailsProvider>(context).userDetails;
    if (timestamp != null) {
      final dateTime = timestamp!.toDate();
      final timeFormatter = DateFormat.jm();
      formattedTimestamp = timeFormatter.format(dateTime);
    }

    return ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.transparent, // Ensure the CircleAvatar has a transparent background
          child: imageUrl == "No Image"
              ? Icon(Icons.camera_alt_rounded, size: 35.0) // Replace Icon with your preferred icon
              : FadeInImage(
            placeholder: AssetImage('path_to_placeholder_image.png'), // Replace with a placeholder image
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        title: Text(chatName),
      subtitle: userDetails.name == senderName
          ? lastMessageText!.contains(
                  "https://firebasestorage.googleapis.com/v0/b/game-42ced.appspot.com/o/chat_images")
              ? Container(
                  child: Row(
                    children: [
                      Text("You: "),
                      Icon(Icons.photo),
                      Text("Photo"),
                    ],
                  ),
                )
              : Text("You: ${lastMessageText}" ?? "")
          : lastMessageText!.contains(
                  "https://firebasestorage.googleapis.com/v0/b/game-42ced.appspot.com/o/chat_images")
              ? Container(
                  child: Row(
                    children: [
                      Text("${senderName}"),
                      Icon(Icons.photo),
                      Text("Photo"),
                    ],
                  ),
                )
              : Text("${senderName}: ${lastMessageText}" ?? ""),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(formattedTimestamp),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
      onTap: () {
        // Implement chat opening functionality

        if (chatType == 'one_on_one') {
          /*Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OneOnOneChatScreen(
                chatId: chatId, // Pass the chatId to the chat screen
                currentUserId: currentUserId,
              ),
            ),
          );

           */
        } else if (chatType == 'group') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => GroupChatScreen(
                chatId: chatId,
                // Pass the chatId to the chat screen
                currentUserId: currentUserId,
                groupName: chatName,
                imageUrl: imageUrl,
                participants: participants,
              ),
            ),
          );
        }
      },
    );
  }
}

class UserListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Fetch user data from Firestore or your database
    // You can use a StreamBuilder to display a dynamic list of users
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Users'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          final users = snapshot.data?.docs ?? [];

          // Sort the user data by name (case-insensitive)
          users.sort((a, b) {
            final nameA = (a['name'] as String).toLowerCase();
            final nameB = (b['name'] as String).toLowerCase();
            return nameA.compareTo(nameB);
          });

          // Create a list of widgets for users
          final userWidgets = users.map((user) {
            final userName = user['name'];
            final userTag = user['tag'];
            final profilePicUrl = user['avatar location'];

            return ListTile(
              leading: ClipOval(
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    profilePicUrl,
                    fit: BoxFit.cover, // or other BoxFit values
                  ),
                ),
              ),
              title: user.id == FirebaseAuth.instance.currentUser!.uid
                  ? Text(userName + " (You)")
                  : Text(userName),
              subtitle: Text(userTag),
              onTap: () {
                // Handle user selection (start a chat with this user)
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OneOnOneChatScreen(
                              otherUserId: user.id,
                              currentUserId:
                                  FirebaseAuth.instance.currentUser!.uid,
                              otherUserName: userName,
                              otherUserAvatar: profilePicUrl,
                              otherUserTag: userTag,
                            )));
              },
            );
          }).toList();

          // Create a list of widgets with spacing
          final spacedWidgets = <Widget>[
            SizedBox(height: 16),
            // Add space above "Create New Group" button
            // Add the "Create New Group" button
            ListTile(
              leading: ClipOval(
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.group_add),
                ),
              ),
              title: Text('Create New Group'),
              onTap: () {
                // Handle navigation to create a new group page
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => NewGroupScreen()),
                );
              },
            ),
            Divider(),
            // Add divider between "Create New Group" and "Chat with Others"
          ];

          // Add the "Chat with Others" text below the "Create New Group" button
          spacedWidgets.add(
            ListTile(
              title: Text(
                'Chat with Others',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );

          // Add the user widgets (list items) to the spacedWidgets list
          spacedWidgets.addAll(userWidgets);

          return ListView(
            children: spacedWidgets,
          );
        },
      ),
    );
  }
}

/*class community extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Candy Crush Level Map'),
        ),
        body: CandyCrushLevelMap(),
      ),
    );
  }
}

class CandyCrushLevelMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Define your level layout here.
    // Each number represents a different type of candy or obstacle.
    // You can use a 2D list to define your level map.

    final levelLayout = [
      [1, 2, 3, 4, 5],
      [3, 4, 5, 1, 2],
      [5, 1, 2, 3, 4],
      [2, 3, 4, 5, 1],
    ];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var row in levelLayout)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var tileType in row)
                  CandyCrushTile(tileType: tileType),
              ],
            ),
        ],
      ),
    );
  }
}

class CandyCrushTile extends StatelessWidget {
  final int tileType;

  CandyCrushTile({required this.tileType});

  @override
  Widget build(BuildContext context) {
    // Implement rendering for different tile types (candies, obstacles, etc.) here.
    // You can use conditional statements or switch cases to customize the appearance
    // of each tile based on the tileType.

    Color tileColor;
    IconData icon;

    switch (tileType) {
      case 1:
        tileColor = Colors.red;
        icon = Icons.circle;
        break;
      case 2:
        tileColor = Colors.blue;
        icon = Icons.square;
        break;
      case 3:
        tileColor = Colors.green;
        icon = Icons.home;
        break;
      case 4:
        tileColor = Colors.yellow;
        icon = Icons.star;
        break;
      case 5:
        tileColor = Colors.purple;
        icon = Icons.email;
        break;
      default:
        tileColor = Colors.grey;
        icon = Icons.block;
        break;
    }

    return Container(
      width: 50,
      height: 50,
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}
 */
