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
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTasks();
  }

  Future<void> _loadUserData() async {
    String name = await fetchValue('username') ?? 'User';
    int points = await fetchValue('points') ?? 0;
    setState(() {
      _username = name;
      _points = points;
    });
  }

  Future<void> _loadTasks() async {
    final taskInfo = TaskInfo();
    final tasks = await taskInfo.readTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.day}/${date.month}/${date.year}';
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
                MaterialPageRoute(builder: (context) => AddTask()),
              );
              _loadTasks(); // Reload tasks after adding a new one
            },
            icon: Icon(Icons.add),
          ),
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditInfo()),
              );
              await _loadUserData();
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
              style: TextStyle(fontSize: 48, color: Colors.white),
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Text(
                "You have $_points points available",
                style: TextStyle(fontSize: 21, color: Colors.white),
              ),
            ),
            SizedBox(height: 40),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Text(
                "Available Tasks:",
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            Expanded(
              child:
                  _tasks.isEmpty
                      ? Center(
                        child: Text(
                          "No tasks available",
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            elevation: 5,
                            color: const Color.fromARGB(255, 24, 24, 24),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          task['name'],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          "${task['points']} points",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.white70,
                                        size: 16,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        _formatDate(task['date']),
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      SizedBox(width: 16),
                                      Icon(
                                        Icons.access_time,
                                        color: Colors.white70,
                                        size: 16,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        task['time'],
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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
