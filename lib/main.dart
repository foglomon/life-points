import 'package:flutter/material.dart';
import 'package:life_points/settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(
            color: Colors.white,
          ), // Set the back button color globally
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder:
            (context) => Scaffold(
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
                  IconButton(onPressed: () {
                    // TODO(foglomon): User profile sign up and log in page
                  }, icon: Icon(Icons.account_circle_outlined), color: Colors.white),
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
              body: Container(color: Colors.grey[900]),
            ),
      ),
    );
  }
}
