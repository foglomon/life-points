import 'package:flutter/material.dart';
import 'package:life_points/file_io.dart';

class DeleteTask extends StatefulWidget {
  const DeleteTask({super.key});

  @override
  State<DeleteTask> createState() => _DeleteTaskState();
}

class _DeleteTaskState extends State<DeleteTask> {
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
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

  Future<void> _deleteTask(int index) async {
    try {
      final taskInfo = TaskInfo();
      _tasks.removeAt(index);
      await taskInfo.writeTasks(_tasks);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Task deleted successfully!')));
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting task: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text(
          'Delete Tasks',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.grey[900],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.black, height: 1.5),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
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
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          task['name'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            if (!(task['isUntimed'] ?? false)) ...[
                              Text(
                                'Date: ${_formatDate(task['date'])}',
                                style: TextStyle(color: Colors.white70),
                              ),
                              Text(
                                'Time: ${task['time']}',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ] else ...[
                              Text(
                                'Untimed Task',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                            Text(
                              'Points: ${task['points']}',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        trailing: TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.grey[900],
                                  title: Text(
                                    'Delete Task',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: RichText(
                                    text: TextSpan(
                                      style: TextStyle(color: Colors.white70),
                                      children: [
                                        TextSpan(
                                          text:
                                              'Are you sure you want to delete "',
                                        ),
                                        TextSpan(
                                          text: '${task['name']}',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(text: '"?'),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _deleteTask(index);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.delete, color: Colors.red),
                          label: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.1),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
