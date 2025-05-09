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
                title: Center(
                  child: const Text(
                    'LIFE POINTS',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                backgroundColor: Colors.grey[900],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Container(color: Colors.black, height: 1.5),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    // TODO(foglomon): Write code for the hamburger menu
                  },
                ),
                actions: [
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
