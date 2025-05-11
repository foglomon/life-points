import 'package:flutter/material.dart';
import 'package:life_points/file_io.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _nameController = TextEditingController();

  void _saveData() async {
    String name = _nameController.text;
    if (name.isNotEmpty) {
      final userInfo = UserInfo();
      await userInfo.writeData(name); // Save the name using the utility class
  
      if (!mounted) return; // Ensure the widget is still in the tree
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Name saved successfully!')),
      );
  
      Navigator.pop(context, name); // Pass the updated name back to the previous screen
    } else {
      if (!mounted) return; // Ensure the widget is still in the tree
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a name.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Container(
          height: 600,
          width: 350,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'LIFE POINTS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                          fontSize: 47,
                        ),
                      ),
                      Text(
                        'Login to your account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                          cursorColor: Colors.white38,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveData,
                        child: Text('Save'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}