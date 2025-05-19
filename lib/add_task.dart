import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:life_points/storage.dart';
import 'package:life_points/home_page.dart';
import 'package:life_points/settings.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  int _selectedIndex = 1;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isUntimed = false;
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homepage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Settings()),
      );
    }
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: Colors.blue,
                onPrimary: Colors.white,
                surface: Colors.grey[900]!,
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null && mounted) {
        setState(() {
          selectedDate = picked;
        });
      }
    } catch (e) {
      debugPrint('Error selecting date: $e');
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    try {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: Colors.blue,
                onPrimary: Colors.white,
                surface: Colors.grey[900]!,
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null && mounted) {
        setState(() {
          selectedTime = picked;
        });
      }
    } catch (e) {
      debugPrint('Error selecting time: $e');
    }
  }

  void _saveTask() async {
    if (_taskNameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a task name')));
      return;
    }

    if (_pointsController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter points')));
      return;
    }

    if (!isUntimed) {
      if (selectedDate == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select a date')));
        return;
      }

      if (selectedTime == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select a time')));
        return;
      }
    }

    final task = {
      'name': _taskNameController.text,
      'points': int.parse(_pointsController.text),
      'isUntimed': isUntimed,
      'date': isUntimed ? null : selectedDate?.toIso8601String(),
      'time':
          isUntimed ? null : '${selectedTime!.hour}:${selectedTime!.minute}',
      'completed': false,
    };

    try {
      final tasks = await Storage.getTasks();
      tasks.add(task);
      await Storage.saveTasks(tasks);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Task saved successfully!')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving task: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text(
          'Add Task',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.grey[900],
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.black, height: 1.5),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _taskNameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Task Name',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _pointsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Points',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              SizedBox(height: 16),
              SwitchListTile(
                title: Text(
                  'Untimed Task',
                  style: TextStyle(color: Colors.white),
                ),
                value: isUntimed,
                onChanged: (bool value) {
                  setState(() {
                    isUntimed = value;
                  });
                },
                activeColor: Colors.blue,
              ),
              if (!isUntimed) ...[
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _selectDate(context),
                        icon: Icon(Icons.calendar_today),
                        label: Text(
                          selectedDate == null
                              ? 'Select Date'
                              : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _selectTime(context),
                        icon: Icon(Icons.access_time),
                        label: Text(
                          selectedTime == null
                              ? 'Select Time'
                              : '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Save Task'),
              ),
            ],
          ),
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
