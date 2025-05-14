import 'package:flutter/material.dart';
import 'package:life_points/add_task.dart';
import 'package:life_points/edit_info.dart';
import 'package:life_points/settings.dart';
import 'package:life_points/storage.dart';
import 'package:life_points/overdue_service.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String _username = "User";
  int _points = 0;
  List<Map<String, dynamic>> _tasks = [];
  final OverdueService _overdueService = OverdueService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTasks();

    // Start the overdue service
    _overdueService.startService();

    // Listen for point updates from the service
    _overdueService.addPointsUpdateListener(_handlePointsUpdate);
  }

  @override
  void dispose() {
    // Remove the listener when disposing
    _overdueService.removePointsUpdateListener(_handlePointsUpdate);
    _overdueService.stopService();
    super.dispose();
  }

  // Callback for when points are updated by the overdue service
  void _handlePointsUpdate(int newPoints) {
    debugPrint('Home page received points update: $newPoints');
    setState(() {
      _points = newPoints;
    });

    // Show a snackbar to inform the user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Points deducted due to overdue tasks! New total: $_points',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _loadUserData() async {
    final username = await Storage.getUsername();
    final points = await Storage.getPoints();
    setState(() {
      _username = username;
      _points = points;
    });
  }

  Future<void> _loadTasks() async {
    final tasks = await Storage.getTasks();

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

        return aDateTime.compareTo(bDateTime);
      } catch (e) {
        return 0;
      }
    });

    setState(() {
      _tasks = tasks;
    });
  }

  Future<void> _updatePoints(int points) async {
    final newPoints = _points + points;
    await Storage.savePoints(newPoints);
    setState(() {
      _points = newPoints;
    });
  }

  Future<void> _completeTask(int index) async {
    final task = _tasks[index];
    if (task['completed'] == true) return;

    task['completed'] = true;
    await Storage.saveTasks(_tasks);
    await _updatePoints(task['points'] as int);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task completed! +${task['points']} points')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          'Life Points',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Settings()),
              );
              _loadTasks(); // Reload tasks after returning from settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[800],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditInfo(currentName: _username),
                      ),
                    );
                    if (result != null) {
                      await Storage.saveUsername(result);
                      setState(() {
                        _username = result;
                      });
                    }
                  },
                  child: Text(
                    _username,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '$_points points',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                final isCompleted = task['completed'] == true;
                final isUntimed = task['isUntimed'] == true;

                // Determine if the task is overdue
                bool isOverdue = false;
                Duration? timeRemaining;
                if (!isUntimed && !isCompleted) {
                  try {
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
                    isOverdue = taskDateTime.isBefore(now);
                    if (!isOverdue) {
                      timeRemaining = taskDateTime.difference(now);
                    }
                  } catch (e) {
                    isOverdue = false;
                  }
                }

                String? subtitleText;
                if (!isUntimed) {
                  final dateStr = task['date'].split('T')[0];
                  final timeStr = task['time'];
                  if (isOverdue) {
                    subtitleText = '$dateStr $timeStr   •   Overdue';
                  } else if (timeRemaining != null) {
                    String remaining;
                    if (timeRemaining.inDays > 0) {
                      remaining =
                          '${timeRemaining.inDays}d ${timeRemaining.inHours % 24}h remaining';
                    } else if (timeRemaining.inHours > 0) {
                      remaining =
                          '${timeRemaining.inHours}h ${timeRemaining.inMinutes % 60}m remaining';
                    } else if (timeRemaining.inMinutes > 0) {
                      remaining = '${timeRemaining.inMinutes}m remaining';
                    } else {
                      remaining = 'Less than a minute remaining';
                    }
                    subtitleText = '$dateStr $timeStr   •   $remaining';
                  } else {
                    subtitleText = '$dateStr $timeStr';
                  }
                }

                return Card(
                  color: isOverdue ? Colors.red[900] : Colors.grey[800],
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      task['name'],
                      style: TextStyle(
                        color: Colors.white,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle:
                        isUntimed
                            ? null
                            : Text(
                              subtitleText!,
                              style: TextStyle(
                                color:
                                    isOverdue
                                        ? Colors.redAccent
                                        : Colors.white70,
                                fontWeight: isOverdue ? FontWeight.bold : null,
                              ),
                            ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '+${task['points']}',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            isCompleted
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: isCompleted ? Colors.green : Colors.white,
                          ),
                          onPressed: () => _completeTask(index),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTask()),
          );
          _loadTasks(); // Reload tasks after adding a new one
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }
}
