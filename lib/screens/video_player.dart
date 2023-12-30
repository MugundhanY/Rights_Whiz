import 'package:app_name/screens/button_screen.dart';
import 'package:app_name/screens/home.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String language;
  final String location;
  final int  NoOfImage;
  final String chapNo;
  const VideoPlayerScreen({
    super.key,
    required this.language,
    required this.location,
    required this.NoOfImage,
    required this.chapNo,
  });

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  String videoValue = "";
  bool isVideoLoading = true;

  @override
  void initState() {
    fetchAndSortLeaderboard();
    super.initState();

    // Lock the orientation to landscape mode when the video starts playing
    /*SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

     */
  }

  Future<void> fetchAndSortLeaderboard() async {
    final DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .doc(widget.location)
        .get();

    setState(() {
      if (docSnapshot.exists && docSnapshot.data() != null) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

        if (data.containsKey('${widget.language}_video')) {
          videoValue = data[widget.language + '_video'];
          print(videoValue);

          // Initialize the VideoPlayerController here
          _videoPlayerController = VideoPlayerController.network(videoValue)
            ..initialize().then((_) {
              setState(() {
                isVideoLoading = false;

                // Initialize ChewieController with desired properties
                _chewieController = ChewieController(
                  videoPlayerController: _videoPlayerController,
                  aspectRatio: 16 / 9,
                  fullScreenByDefault: true,
                  autoInitialize: true,
                  autoPlay: true,
                );

                // Add a listener for when the video ends
                _videoPlayerController.addListener(() {
                  if (_videoPlayerController.value.position ==
                      _videoPlayerController.value.duration) {
                    // Release the lock on orientation when the video ends
                    /*SystemChrome.setPreferredOrientations([
                      DeviceOrientation.portraitUp,
                      DeviceOrientation.portraitDown,
                      DeviceOrientation.landscapeLeft,
                      DeviceOrientation.landscapeRight,
                    ]);

                     */

                    // Navigate to the home screen when the video ends
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ThreeImageButtonScreen(language: widget.language, location: widget.location, NoOfImage: widget.NoOfImage, chapNo: widget.chapNo,)),
                    );
                  }
                });
              });
            });
        } else {
          // Handle the case where the field does not exist
        }
      } else {
        // Handle the case where the document does not exist or data is null
      }
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (isVideoLoading)
            Center(child: CircularProgressIndicator())
          else
            Chewie(controller: _chewieController),
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => home()),
                );
              },
              child: Icon(
                Icons.home_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
