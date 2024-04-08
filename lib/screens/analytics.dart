import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_name/widgets/sidebar.dart'; // Assuming you have this widget implemented
import 'package:fl_chart/fl_chart.dart';

class AnalyticsData {
  final String chap;
  final String qno;
  final int correctCount;
  final int incorrectCount;

  AnalyticsData({
    required this.chap,
    required this.qno,
    required this.correctCount,
    required this.incorrectCount,
  });
}

class AnalyticsPage extends StatefulWidget {
  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final String currentPage = 'Analytics';
  late List<AnalyticsData> _analyticsDataList;
  late String _selectedChap = '1';
  late String _selectedQno = '0';
  late String _highestChap = '1';
  late String _highestQno = '0';

  @override
  void initState() {
    super.initState();
    _analyticsDataList = [];
    fetchAnalyticsData();
  }

  // Function to fetch analytics data from Firestore
  void fetchAnalyticsData() async {
    final snapshot = await FirebaseFirestore.instance.collection('analytics').get();
    final List<AnalyticsData> dataList = snapshot.docs.map((doc) {
      final documentId = doc.id;
      final chapterAndSection = _extractNumbersFromDocumentId(documentId);
      final correctCount = doc['correct'] ?? 0;
      final incorrectCount = doc['incorrect'] ?? 0;
      return AnalyticsData(
        chap: chapterAndSection[0],
        qno: chapterAndSection[1],
        correctCount: correctCount,
        incorrectCount: incorrectCount,
      );
    }).toList();

    setState(() {
      _analyticsDataList = dataList;
      _highestChap = findHighestChapter(_analyticsDataList);
      _highestQno = findHighestQno(_analyticsDataList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentPage: currentPage),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 220, 64, 72),
        title: Text('Analytics'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('analytics').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          // Check if there are no documents
          if (snapshot.data?.docs.isEmpty ?? true) {
            return Center(
              child: Text('No data available'),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100, // Adjust the width according to your preference
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.grey[200],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _selectedChap == '1' ? null : _switchToPreviousChapter,
                          icon: Icon(Icons.arrow_back_ios),
                        ),
                        Text(
                          'Chapter No: $_selectedChap',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        IconButton(
                          onPressed: _selectedChap == _highestChap ? null : _switchToNextChapter,
                          icon: Icon(Icons.arrow_forward_ios),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.grey[200],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _selectedQno == '0' ? null : _switchToPreviousQno,
                          icon: Icon(Icons.arrow_back_ios),
                        ),
                        Text(
                          'Q.No: ${int.parse(_selectedQno) + 1}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        IconButton(
                          onPressed: _selectedQno == _highestQno ? null : _switchToNextQno,
                          icon: Icon(Icons.arrow_forward_ios),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: _buildBarChart(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<String> _extractNumbersFromDocumentId(String documentId) {
    final RegExp regex = RegExp(r'\d+');
    final List<String> numbers = regex.allMatches(documentId).map((m) =>
    m.group(0)!).toList();
    return numbers;
  }

  String findHighestChapter(List<AnalyticsData> data) {
    int highestChapter = 0;
    for (var item in data) {
      if (int.parse(item.chap) > highestChapter) {
        highestChapter = int.parse(item.chap);
      }
    }
    return highestChapter.toString();
  }

  String findHighestQno(List<AnalyticsData> data) {
    int highestQno = 0;
    for (var item in data) {
      if (int.parse(item.qno) > highestQno) {
        highestQno = int.parse(item.qno);
      }
    }
    return highestQno.toString();
  }

  void _switchToPreviousChapter() {
    setState(() {
      _selectedChap = _getPreviousChap(_selectedChap);
    });
  }

  void _switchToNextChapter() {
    setState(() {
      _selectedChap = _getNextChap(_selectedChap);
    });
  }

  void _switchToPreviousQno() {
    setState(() {
      _selectedQno = _getPreviousQno(_selectedQno);
    });
  }

  void _switchToNextQno() {
    setState(() {
      _selectedQno = _getNextQno(_selectedQno);
    });
  }

  String _getPreviousChap(String currentChap) {
    // If currentChap is empty or '1', return '1' (start case)
    if (currentChap.isEmpty || currentChap == '1') {
      return '1';
    }
    // Otherwise, decrement currentChap
    return (int.parse(currentChap) - 1).toString();
  }

  String _getNextChap(String currentChap) {
    // If currentChap is empty or '13', return '13' (end case)
    if (currentChap.isEmpty || currentChap == '13') {
      return '13';
    }
    // Otherwise, increment currentChap
    return (int.parse(currentChap) + 1).toString();
  }

  String _getPreviousQno(String currentQno) {
    // If currentQno is empty or '1', return '1' (start case)
    if (currentQno.isEmpty || currentQno == '0') {
      return '0';
    }
    // Otherwise, decrement currentQno
    return (int.parse(currentQno) - 1).toString();
  }

  String _getNextQno(String currentQno) {
    // If currentQno is empty or '124', return '124' (end case)
    if (currentQno.isEmpty || currentQno == '5') {
      return '5';
    }
    // Otherwise, increment currentQno
    return (int.parse(currentQno) + 1).toString();
  }

  BarChart _buildBarChart() {
    print('Selected Chap: $_selectedChap');
    print('Selected Qno: $_selectedQno');

    // Filter data based on selected chapter and question number
    final filteredData = _analyticsDataList.where((data) =>
    data.chap == _selectedChap && data.qno == _selectedQno).toList();
    print('Filtered Data: $filteredData');

    // Generate bar chart data based on filtered data
    List<BarChartGroupData> barGroups = [];
    filteredData.forEach((data) {
      barGroups.add(
        BarChartGroupData(
          x: 0,
          barsSpace: 16,
          barRods: [
            BarChartRodData(
              toY: data.correctCount.toDouble(),
              color: Colors.green,
              width: 32,
              borderRadius: BorderRadius.circular(8),
            ),
            BarChartRodData(
              toY: data.incorrectCount.toDouble(),
              color: Colors.red,
              width: 32,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
      );
    });
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        barGroups: barGroups,
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String title;
              switch (rodIndex) {
                case 0:
                  title = 'Correct';
                  break;
                case 1:
                  title = 'Incorrect';
                  break;
                default:
                  title = '';
              }
              return BarTooltipItem(
                title,
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                children: <TextSpan>[
                  TextSpan(
                    text: ' : ${rod.toY.toInt()}',
                    style: TextStyle(color: Colors.yellowAccent),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
