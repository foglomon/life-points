import 'package:flutter/material.dart';
import 'package:life_points/delete_task.dart';
import 'package:life_points/storage.dart';
import 'package:life_points/home_page.dart';
import 'package:life_points/add_task.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  int _selectedIndex = 2;
  String selectedFrequency = 'Every Day';
  final TextEditingController pointsController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => Homepage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => AddTask(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadOverdueSettings();
    _loadProfile();
  }

  @override
  void dispose() {
    pointsController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> _loadOverdueSettings() async {
    final settings = await Storage.getOverdueSettings();
    setState(() {
      selectedFrequency = settings['frequency'];
      pointsController.text = settings['points'].toString();
    });
  }

  Future<void> _saveOverdueSettings() async {
    if (pointsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter points to deduct')),
      );
      return;
    }

    final points = int.tryParse(pointsController.text);
    if (points == null || points < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid positive number')),
      );
      return;
    }

    await Storage.saveOverdueSettings(selectedFrequency, points);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully!')),
    );
  }

  Future<void> _loadProfile() async {
    final username = await Storage.getUsername();
    setState(() {
      nameController.text = username ?? "";
    });
  }

  Future<void> _saveProfile() async {
    String name = nameController.text;
    if (name.isNotEmpty) {
      await Storage.saveUsername(name);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name saved successfully!')));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a name.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text(
          'Settings',
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
              Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Name',
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
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text('Save Profile'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              Divider(color: Colors.white24),
              SizedBox(height: 16),
              Column(
                children: [
                  Text(
                    'Task Management',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text(
                      'Delete Tasks',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    subtitle: Text(
                      'Remove tasks without adding points',
                      style: TextStyle(color: Colors.white70),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DeleteTask()),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Overdue Task Penalties',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deduct points on overdue tasks',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedFrequency,
                          dropdownColor: Colors.grey[800],
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Frequency',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[600]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                          items:
                              [
                                'Never',
                                'Every Minute',
                                'Every Hour',
                                'Every Day',
                                'Every Week',
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedFrequency = newValue;
                                if (newValue == 'Never') {
                                  pointsController.text = '0';
                                }
                              });
                            }
                          },
                        ),
                        SizedBox(height: 16),
                        if (selectedFrequency != 'Never')
                          TextField(
                            controller: pointsController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Points to deduct',
                              labelStyle: TextStyle(color: Colors.white70),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[600]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Point deduction is disabled',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _saveOverdueSettings,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50),
                          ),
                          child: Text('Save Settings'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              Divider(color: Colors.white24),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.restart_alt, color: Colors.white),
                  label: Text(
                    'Reset App',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            backgroundColor: Colors.grey[900],
                            title: Text(
                              'Reset App',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: Text(
                              'This will erase all your data and return the app to its initial state. Are you sure?',
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                              ),
                              TextButton(
                                child: Text(
                                  'Reset',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                              ),
                            ],
                          ),
                    );
                    if (confirm == true) {
                      await Storage.clearAllData();
                      if (!mounted) return;
                      Navigator.pushNamedAndRemoveUntil(
                        // ignore: use_build_context_synchronously
                        context,
                        '/',
                        (route) => false,
                      );
                    }
                  },
                ),
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
