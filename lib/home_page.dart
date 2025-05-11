import 'package:flutter/material.dart';
import 'package:life_points/settings.dart';
import 'package:life_points/file_io.dart'; // Import the utility function

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String _username = "User"; // Default value

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    String name = await fetchUsername(); // Use the utility function
    setState(() {
      _username = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        title: const Text(
          'LIFE POINTS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Colors.grey[900],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.black, height: 1.5),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Settings()),
              );
              await _loadUsername(); // Always reload after returning
            },
            icon: Icon(Icons.account_circle_outlined),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Settings()),
              );
            },
            icon: Icon(Icons.settings),
            color: Colors.white,
          ),
        ],
      ),
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        padding: const EdgeInsets.all(16.5),
        color: Colors.grey[900],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, $_username",
              style: TextStyle(fontSize: 48),
            ), // Username is dynamically fetched
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Text(
                "You have <points> points available",
                style: TextStyle(fontSize: 21),
              ),
            ), // TODO: Replace <points> with actual points
            Container(
              margin: EdgeInsets.only(top: 200),
              child: Column(
                children: [
                  Text("Available Tasks:", style: TextStyle(fontSize: 24)),
                  SizedBox(
                    width: double.maxFinite,
                    height: 150,
                    child: Card(
                      elevation: 5,
                      color: const Color.fromARGB(255, 24, 24, 24),
                      child: Text("<Task name>"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
