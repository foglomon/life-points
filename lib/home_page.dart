import 'package:flutter/material.dart';
import 'package:life_points/add_task.dart';
import 'package:life_points/settings.dart';
import 'package:life_points/storage.dart';
import 'package:life_points/overdue_service.dart';
import 'package:life_points/signup_page.dart';
import 'package:life_points/tutorial_page.dart';

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
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddTask()),
      ).then((_) {
        _loadTasks();
      });
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Settings()),
      ).then((_) {
        _loadTasks();
        _loadUserData();
      });
    }
  }

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

    if (username == null && mounted) {
      // Show the signup page if username is not set
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SignupPage(),
          fullscreenDialog: true,
        ),
      );

      if (result == true) {
        // Get the new username after signup
        final newUsername = await Storage.getUsername();
        if (newUsername != null && mounted) {
          // Show the tutorial after successful signup
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TutorialPage(username: newUsername),
            ),
          );
          // Set the state directly instead of calling _loadUserData again
          setState(() {
            _username = newUsername;
            _points = points;
          });
        }
      }
    } else {
      setState(() {
        _username = username ?? "User";
        _points = points;
      });
    }
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

    bool isOverdue = false;
    final isUntimed = task['isUntimed'] == true;
    if (!isUntimed) {
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
      } catch (e) {
        isOverdue = false;
      }
    }

    task['completed'] = true;
    await Storage.saveTasks(_tasks);
    setState(() {});
    if (!isOverdue) {
      await _updatePoints(task['points'] as int);
    }

    if (!mounted) return;
    if (isOverdue && !isUntimed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task completed, but no points awarded (overdue)'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task completed! +${task['points']} points')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Life Points',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            fontSize: 28,
          ),
        ),
        backgroundColor: Colors.grey[900],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTasks,
        color: Colors.blue,
        backgroundColor: Colors.grey[900],
        child: Column(
          children: [
            // User info container
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.blueGrey.shade800, Colors.blueGrey.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      SizedBox(width: 12),
                      Text(
                        _username,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(50),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.stars, color: Colors.amber, size: 24),
                        SizedBox(width: 6),
                        Text(
                          '$_points',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'points',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  final availableTasks =
                      _tasks
                          .where((task) => task['completed'] != true)
                          .toList();
                  final completedTasks =
                      _tasks
                          .where((task) => task['completed'] == true)
                          .toList();
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      // Available tasks section title
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        child: Text(
                          'Available Tasks (${availableTasks.length})',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Available tasks or no tasks message
                      if (availableTasks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Text(
                            'No Available Tasks',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else
                        ...availableTasks.map((task) {
                          final index = _tasks.indexOf(task);
                          final isCompleted = task['completed'] == true;
                          final isUntimed = task['isUntimed'] == true;

                          // Determine if the task is overdue
                          bool isOverdue = false;
                          Duration? timeRemaining;
                          if (!isUntimed && !isCompleted) {
                            try {
                              final taskDate = DateTime.parse(task['date']);
                              final timeParts = (task['time'] as String).split(
                                ':',
                              );
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
                                remaining =
                                    '${timeRemaining.inMinutes}m remaining';
                              } else {
                                remaining = 'Less than a minute remaining';
                              }
                              subtitleText =
                                  '$dateStr $timeStr   •   $remaining';
                            } else {
                              subtitleText = '$dateStr $timeStr';
                            }
                          }

                          return Card(
                            color:
                                isOverdue ? Colors.red[900] : Colors.grey[800],
                            margin: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text(
                                task['name'],
                                style: TextStyle(
                                  color: Colors.white,
                                  decoration:
                                      isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
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
                                          fontWeight:
                                              isOverdue
                                                  ? FontWeight.bold
                                                  : null,
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
                                      color:
                                          isCompleted
                                              ? Colors.green
                                              : Colors.white,
                                    ),
                                    onPressed: () => _completeTask(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      // Completed tasks section (collapsible)
                      if (completedTasks.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                              unselectedWidgetColor: Colors.white70,
                              colorScheme: Theme.of(
                                context,
                              ).colorScheme.copyWith(surface: Colors.grey[900]),
                            ),
                            child: ExpansionTile(
                              initiallyExpanded: true,
                              backgroundColor: Colors.grey[900],
                              collapsedBackgroundColor: Colors.grey[900],
                              title: Text(
                                'Completed Tasks (${completedTasks.length})',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              children:
                                  completedTasks.map((task) {
                                    final isUntimed = task['isUntimed'] == true;
                                    String? subtitleText;
                                    if (!isUntimed) {
                                      final dateStr =
                                          task['date'].split('T')[0];
                                      final timeStr = task['time'];
                                      subtitleText = '$dateStr $timeStr';
                                    }
                                    return Card(
                                      color: Colors.grey[850],
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          task['name'],
                                          style: TextStyle(
                                            color: Colors.white54,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                        subtitle:
                                            isUntimed
                                                ? null
                                                : Text(
                                                  subtitleText!,
                                                  style: TextStyle(
                                                    color: Colors.white38,
                                                  ),
                                                ),
                                        trailing: Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Tooltip(
        message: 'Add new task',
        preferBelow: false,
        verticalOffset: 25,
        child: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTask()),
            );
            _loadTasks();
          },
          backgroundColor: Colors.blue,
          icon: Icon(Icons.add),
          label: Text('Add Task'),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[850],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Task'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
