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

    // Sort tasks
    tasks.sort((a, b) {
      // If both tasks are untimed, keep their original order
      if ((a['isUntimed'] ?? false) && (b['isUntimed'] ?? false)) {
        return 0;
      }

      // If only one task is untimed, put it at the end
      if (a['isUntimed'] ?? false) return 1;
      if (b['isUntimed'] ?? false) return -1;

      try {
        // For timed tasks, compare their dates and times
        final aDate = DateTime.parse(a['date']);
        final bDate = DateTime.parse(b['date']);

        final aTimeParts = (a['time'] as String).split(':');
        final bTimeParts = (b['time'] as String).split(':');

        final aDateTime = DateTime(
          aDate.year,
          aDate.month,
          aDate.day,
          int.parse(aTimeParts[0]),
          int.parse(aTimeParts[1]),
        );

        final bDateTime = DateTime(
          bDate.year,
          bDate.month,
          bDate.day,
          int.parse(bTimeParts[0]),
          int.parse(bTimeParts[1]),
        );

        // Compare the full date and time
        return aDateTime.compareTo(bDateTime);
      } catch (e) {
        debugPrint('Error sorting tasks: $e');
        return 0;
      }
    });

    // Print sorted tasks for debugging
    for (var task in tasks) {
      if (!(task['isUntimed'] ?? false)) {
        debugPrint(
          'Task: ${task['name']}, Date: ${task['date']}, Time: ${task['time']}',
        );
      } else {
        debugPrint('Untimed Task: ${task['name']}');
      }
    }

    setState(() {
      _tasks = tasks;
    });
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.day}/${date.month}/${date.year}';
  }

  bool _isTaskOverdue(Map<String, dynamic> task) {
    if (task['isUntimed'] ?? false) return false;

    final taskDate = DateTime.parse(task['date']);
    final timeParts = task['time'].split(':');
    final taskDateTime = DateTime(
      taskDate.year,
      taskDate.month,
      taskDate.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    return taskDateTime.isBefore(DateTime.now());
  }

  String _formatTimeRemaining(Map<String, dynamic> task) {
    if (task['isUntimed'] ?? false) return '';

    final taskDate = DateTime.parse(task['date']);
    final timeParts = (task['time'] as String).split(':');
    final taskDateTime = DateTime(
      taskDate.year,
      taskDate.month,
      taskDate.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    final now = DateTime.now();
    final difference = taskDateTime.difference(now);

    if (difference.isNegative) {
      return 'Overdue';
    }

    if (difference.inDays > 0) {
      return '${difference.inDays}d remaining';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h remaining';
    } else {
      return '${difference.inMinutes}m remaining';
    }
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
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Settings()),
              );
              _loadTasks(); // Always reload tasks when returning from settings
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
                            color:
                                _isTaskOverdue(task)
                                    ? const Color.fromARGB(
                                      255,
                                      80,
                                      0,
                                      0,
                                    ) // Dark red for overdue tasks
                                    : const Color.fromARGB(
                                      255,
                                      24,
                                      24,
                                      24,
                                    ), // Original dark color
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
                                      if (!(task['isUntimed'] ?? false)) ...[
                                        Icon(
                                          Icons.calendar_today,
                                          color: Colors.white70,
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          _formatDate(task['date']),
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
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
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Text(
                                          _formatTimeRemaining(task),
                                          style: TextStyle(
                                            color:
                                                _isTaskOverdue(task)
                                                    ? Colors.red
                                                    : Colors.white70,
                                          ),
                                        ),
                                      ] else ...[
                                        Icon(
                                          Icons.schedule,
                                          color: Colors.white70,
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Untimed Task',
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
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
