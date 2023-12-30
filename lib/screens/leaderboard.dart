import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/sidebar.dart';

class leaderboard extends StatefulWidget {
  const leaderboard({super.key});

  @override
  State<leaderboard> createState() => _leaderboardState();
}

class _leaderboardState extends State<leaderboard> {
  List<Map<String, dynamic>> leaderboardData = [];
  final String currentPage = 'Leaderboard';
  @override
  void initState() {
    super.initState();
    fetchAndSortLeaderboard();
  }

  Future<void> fetchAndSortLeaderboard() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('Score', descending: true)
        .get();

    setState(() {
      leaderboardData = snapshot.docs.map((DocumentSnapshot doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['name'],
          'Score': data['Score'],
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentPage: currentPage),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 220, 64, 72),
        title: Text('Leaderboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Players',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: leaderboardData.length,
                itemBuilder: (context, index) {
                  final player = leaderboardData[index];
                  final placeNumber = (index + 1).toString(); // Calculate place number
                  return ListTile(
                    title: Text(
                      '$placeNumber. ${player['name']}', // Display place number and player's name
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: index < 3
                            ? FontWeight.bold // Highlight top 3 players
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text('Score: ${player['Score']}', ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
