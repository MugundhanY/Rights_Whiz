import 'dart:io';

import 'package:app_name/screens/group_appbar_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';


class GroupChatScreen extends StatefulWidget {
  final String chatId; // Unique chat ID for group chat
  final String currentUserId; // Current user's ID
  final String groupName; // Group name
  final String imageUrl;
  final Map<String, dynamic>participants;

  GroupChatScreen({
    required this.chatId,
    required this.currentUserId,
    required this.groupName,
    required this.imageUrl,
    required this.participants,
  });

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  final Color myMessageColor =
      Colors.green; // Color for messages sent by the current user
  final Color otherMessageColor =
      Colors.blue; // Color for messages sent by others

  Future<String> fetchUserName(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      return userData['name'] as String;
    }
    return ''; // Return an empty string if user not found or in case of an error
  }

  Future<String?> uploadImageToFirebaseStorage(String imagePath) async {
    try {
      final Reference storageReference = FirebaseStorage.instance.ref().child('chat_images').child(DateTime.now().millisecondsSinceEpoch.toString());
      final UploadTask uploadTask = storageReference.putFile(File(imagePath));
      final TaskSnapshot storageTaskSnapshot = await uploadTask.whenComplete(() {});
      final String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void _handleAttachmentButtonPressed() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageUrl = await uploadImageToFirebaseStorage(pickedFile.path);

      if (imageUrl != null) {
        // Send the image URL as an image message
        _sendMessage(imageUrl, messageType: 'image');
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 220, 64, 72), // Customize the app bar color
        title: InkWell( // Wrap the Row with InkWell
          onTap: () {
            // Navigate to the group details screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => GroupDetailsScreen(
                  groupName: widget.groupName,
                  imageUrl: widget.imageUrl,
                  participants: widget.participants, // Pass the list of members here
                ),
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.transparent, // Ensure the CircleAvatar has a transparent background
                child: widget.imageUrl == "No Image"
                    ? Icon(Icons.camera_alt_rounded, size: 35.0) // Replace Icon with your preferred icon
                    : FadeInImage(
                  placeholder: AssetImage('path_to_placeholder_image.png'), // Replace with a placeholder image
                  image: NetworkImage(widget.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16),
              Text(
                widget.groupName,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Implement more options menu
            },
          ),
        ],
      ),
      body: Stack(

    children:[ Image.asset(
      'assets/community_background.png',
      width: double.infinity, // Stretch the image horizontally to fill the screen
      height: double.infinity, // Stretch the image vertically to fill the screen
      fit: BoxFit.fill, // Use BoxFit.fill to fill the entire screen
    ),Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final messages = snapshot.data?.docs ?? [];

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final text = message['text'] as String;
                    final timestamp = (message['timestamp'] as Timestamp).toDate();
                    final sender = message['sender'] as String;
                    final isCurrentUser = sender == widget.currentUserId;
                    final messageColor = isCurrentUser ? myMessageColor : otherMessageColor;

                    if (message.containsKey('type') && message['type'] == 'image') {
                      // Display the image using the Image widget wrapped in ClipRRect
                      return Align(
                        alignment: isCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: messageColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isCurrentUser) // Display sender's name only if it's not the current user
                                FutureBuilder(
                                  future: fetchUserName(sender),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Text(
                                        'Loading...',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text(
                                        'Error',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      );
                                    } else {
                                      return Text(
                                        snapshot.data as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  text,
                                  width: 200, // Adjust the width as needed
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Text(
                                DateFormat.Hm().format(timestamp),
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: 12, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      // Display text messages as before
                      return Align(
                        alignment: isCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: messageColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isCurrentUser) // Display sender's name only if it's not the current user
                                FutureBuilder(
                                  future: fetchUserName(sender),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Text(
                                        'Loading...',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text(
                                        'Error',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      );
                                    } else {
                                      return Text(
                                        snapshot.data as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              Text(
                                text,
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                              Text(
                                DateFormat.Hm().format(timestamp),
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: 12, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
          Divider(height: 1),
          _buildMessageComposer(),
        ],
      ),
    ],
    ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      height: 60,
      color: Color.fromARGB(255, 226, 104, 110),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {
                // Handle text input
              },
              decoration: InputDecoration.collapsed(
                hintText: 'Type a message',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.attach_file),
            onPressed: () {
              // Handle attachment button press
              _handleAttachmentButtonPressed();
            },
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              // Handle send button press
              _sendMessage(_messageController.text);
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text, {String? messageType}) {
    if (text.isNotEmpty) {
      // Create a message map with the "type" field
      final message = {
        'text': text,
        'sender': widget.currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'type': messageType ?? 'text', // Default to 'text' if no messageType is provided
      };

      // Send the message to Firebase
      FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add(message);

      // Update the last message in the chat document
      FirebaseFirestore.instance.collection('chats').doc(widget.chatId).update({
        'lastMessage.text': text,
        'lastMessage.sender': widget.currentUserId,
        'lastMessage.timestamp': FieldValue.serverTimestamp(),
      });

      // Clear the message input field
      _messageController.clear();
    }
  }


  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}


class OneOnOneChatScreen extends StatefulWidget {
  final String otherUserId; // Unique chat ID for one-on-one chat
  final String currentUserId; // Current user's ID
  final String otherUserName;
  final String otherUserAvatar;
  final String otherUserTag;

  OneOnOneChatScreen({required this.otherUserId, required this.currentUserId, required this.otherUserName, required this.otherUserAvatar, required this.otherUserTag});

  @override
  State<OneOnOneChatScreen> createState() => _OneOnOneChatScreenState();
}

class _OneOnOneChatScreenState extends State<OneOnOneChatScreen> {
  String chatId = "";

  void initState() {
    super.initState();
    initializeChat();
  }

  Future<void> initializeChat() async {
    chatId = (await createOrAddToChat(widget.currentUserId, widget.otherUserId))!;
    if (chatId != null) {
      setState(() {}); // Refresh the widget when chatId is updated
    } else {
      // Handle the case where chat creation or addition failed
    }
  }


  Future<String?> createOrAddToChat(String currentUserId, String otherUserId) async {
    try {
      // Define the Firestore collection reference for "chats"
      final CollectionReference chatCollection = FirebaseFirestore.instance.collection('chats');

      // Generate a unique chat ID based on the user IDs
      final chatId = getChatId(currentUserId, otherUserId);

      // Check if a chat already exists with the generated chat ID
      final chatDoc = await chatCollection.doc(chatId).get();

      if (!chatDoc.exists) {
        // If no chat exists, create a new chat document with the specified chatId
        final participants = [currentUserId, otherUserId];

        await chatCollection.doc(chatId).set({
          'participants': participants,
          'type': 'one_on_one',
          'lastMessage': {
            'text': 'has started the chat', // Initialize with an empty message
            'sender': currentUserId, // Initialize with an empty sender
            'timestamp': FieldValue.serverTimestamp(),
          },
        });

        // Return the chat ID
        return chatId;
      } else {
        // If a chat already exists, return the chat ID
        return chatId;
      }
    } catch (e) {
      // Handle any errors here (e.g., Firebase exceptions)
      print('Error creating or adding to chat: $e');
      return null;
    }
  }

// Generate a unique chat ID based on user IDs
  String getChatId(String userId1, String userId2) {
    final List<String> sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }



  final TextEditingController _messageController = TextEditingController();

  final Color myMessageColor =
      Colors.green; // Color for messages sent by the current user
  final Color otherMessageColor =
      Colors.blue; // Color for messages sent by others

  Future<String> fetchUserName(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(
        userId).get();
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      return userData['name'] as String;
    }
    return ''; // Return an empty string if user not found or in case of an error
  }

  Future<String?> uploadImageToFirebaseStorage(String imagePath) async {
    try {
      final Reference storageReference = FirebaseStorage.instance.ref().child(
          'chat_images').child(DateTime
          .now()
          .millisecondsSinceEpoch
          .toString());
      final UploadTask uploadTask = storageReference.putFile(File(imagePath));
      final TaskSnapshot storageTaskSnapshot = await uploadTask
          .whenComplete(() {});
      final String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void _handleAttachmentButtonPressed() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageUrl = await uploadImageToFirebaseStorage(pickedFile.path);

      if (imageUrl != null) {
        // Send the image URL as an image message
        _sendMessage(imageUrl, messageType: 'image');
      }
    }
  }

  Stream<QuerySnapshot> getMessagesStream() {
    // Get the stream for messages in the specific chat
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId) // Use the chatId to specify the chat document
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 220, 64, 72), // Customize the app bar color
        title: InkWell( // Wrap the Row with InkWell
          onTap: () {
            // Navigate to the group details screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OneDetailsScreen(
                      tag: widget.otherUserTag,
                  avatar: widget.otherUserAvatar,
                  name: widget.otherUserName,
                  id: widget.otherUserId,
                ),
              ),
            );
          },
          child: Row(
            children: [
              ClipOval(
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    widget.otherUserAvatar,
                    fit: BoxFit.cover, // or other BoxFit values
                  ),
                ),
              ),
              SizedBox(width: 10),
              Text( widget.otherUserId == widget.currentUserId?
                widget.otherUserName+" (You)" : widget.otherUserName,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Implement more options menu
            },
          ),
        ],
      ),
      body:  Stack(

        children:[ Image.asset(
        'assets/community_background.png',
        width: double.infinity, // Stretch the image horizontally to fill the screen
        height: double.infinity, // Stretch the image vertically to fill the screen
        fit: BoxFit.fill, // Use BoxFit.fill to fill the entire screen
      ),Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: getMessagesStream(), // Use the stream from Firestore
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final messages = snapshot.data?.docs ?? [];

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data()
                    as Map<String, dynamic>;
                    final text = message['text'] as String;
                    final sender = message['sender'] as String;
                    final isCurrentUser =
                        sender == widget.currentUserId;
                    final timestamp = (message['timestamp'] as Timestamp).toDate();
                    final messageColor = isCurrentUser
                        ? myMessageColor
                        : otherMessageColor;

                    if (message.containsKey('type') &&
                        message['type'] == 'image') {
                      // Display the image using the Image widget wrapped in ClipRRect
                      return Align(
                        alignment: isCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: messageColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              text,
                              width: 200, // Adjust the width as needed
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    } else {
                      // Display text messages as before
                      return Align(
                        alignment: isCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: messageColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            text,
                            style: TextStyle(
                                fontSize: 16, color: Colors.white),
                          ),
                        ),
                      );
                    }
                  },
                );

              },
            ),
          ),
          Divider(height: 1),
          _buildMessageComposer(),
        ],
      ),
      ],
    ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      height: 60,
      color: Color.fromARGB(255, 226, 104, 110),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {
                // Handle text input
              },
              decoration: InputDecoration.collapsed(
                hintText: 'Type a message',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.attach_file),
            onPressed: () {
              // Handle attachment button press
              _handleAttachmentButtonPressed();
            },
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              // Handle send button press
              _sendMessage(_messageController.text);
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text, {String? messageType}) {
    if (text.isNotEmpty) {
      // Create a message map with the "type" field
      final message = {
        'text': text,
        'sender': widget.currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'type': messageType ?? 'text',
        // Default to 'text' if no messageType is provided
      };

      // Send the message to Firebase
      FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message);

      // Update the last message in the chat document
      FirebaseFirestore.instance.collection('chats').doc(chatId).update({
        'lastMessage.text': text,
        'lastMessage.sender': widget.currentUserId,
        'lastMessage.timestamp': FieldValue.serverTimestamp(),
      });

      // Clear the message input field
      _messageController.clear();
    }
  }


  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}