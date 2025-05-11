import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder:
          (context) => Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text(
                'Settings',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.grey[900],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: Colors.black, height: 1.5),
              ),
            ),
            body: Container(
              color: Colors.grey[900],
              height: double.infinity,
              width: double.infinity,
              padding: const EdgeInsets.all(16.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Settings",
                      style: TextStyle(fontSize: 48, color: Colors.white),
                    ),
                  ),
                  // TODO: Add setting options here
                ],
              ),
            ),
          ),
    );
  }
}
