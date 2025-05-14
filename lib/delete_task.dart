import 'package:flutter/material.dart';
import 'package:life_points/storage.dart';

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
    final tasks = await Storage.getTasks();
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
      _tasks.removeAt(index);
      await Storage.saveTasks(_tasks);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted successfully!')),
      );
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
      body:
          _tasks.isEmpty
              ? Center(
                child: Text(
                  'No tasks available',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              )
              : ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Card(
                    color: Colors.grey[800],
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(
                        task['name'],
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle:
                          task['isUntimed'] == true
                              ? Text(
                                'Untimed Task',
                                style: TextStyle(color: Colors.white70),
                              )
                              : Text(
                                '${_formatDate(task['date'])} ${task['time']}',
                                style: TextStyle(color: Colors.white70),
                              ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTask(index),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
