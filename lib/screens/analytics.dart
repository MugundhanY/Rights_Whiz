import 'package:app_name/widgets/sidebar.dart';
import 'package:flutter/material.dart';

class analytics extends StatefulWidget {
  const analytics({super.key});

  @override
  State<analytics> createState() => _analyticsState();
}

class _analyticsState extends State<analytics> {
  final String currentPage = 'Analytics';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentPage: currentPage),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 220, 64, 72),
        title: Text('Analytics'),
      ),
      body: Center(),
    );
  }
}
