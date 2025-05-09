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
                child: Container(
                  color: Colors.black,
                  height: 1.5,
                ),
              ),
            ),
            body: Container(color: Colors.grey[900]),
          ),
    );
  }
}
