import 'package:flutter/material.dart';
import 'package:life_points/add_task.dart';
import 'package:life_points/edit_info.dart';
import 'package:life_points/settings.dart';
import 'package:life_points/file_io.dart'; // Import the utility function

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String _username = "User";
  int _points = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String name = await fetchValue('username') ?? 'User';
    int points = await fetchValue('points') ?? 0;
    setState(() {
      _username = name;
      _points = points;
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTask()),
              );
            },
            icon: Icon(Icons.add),
          ),
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditInfo()),
              );
              await _loadUserData(); // Always reload after returning
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
        height: double.infinity,
        width: double.infinity,
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
                "You have $_points points available",
                style: TextStyle(fontSize: 21),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 200),
              child: Column(
                children: [
                  Text("Available Tasks:", style: TextStyle(fontSize: 24)),
                  SizedBox(
                    width: double.infinity,
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
