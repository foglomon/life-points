import 'package:flutter/material.dart';
import 'package:life_points/settings.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
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
                  IconButton(
                    onPressed: () {
                      // TODO: User profile sign up and log in page
                    },
                    icon: Icon(Icons.account_circle_outlined),
                  ),
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
              body: Container(
                height: double.maxFinite,
                width: double.maxFinite,
                padding: const EdgeInsets.all(16.5),
                color: Colors.grey[900],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, <user>",
                      style: TextStyle(fontSize: 48),
                    ), //TODO: get username
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Text(
                        "You have <points> points available",
                        style: TextStyle(fontSize: 21),
                      ),
                    ), //TODO: get points
                    Container(
                      margin: EdgeInsets.only(top: 200),
                      child: Column(
                        children: [
                          Text(
                            "Available Tasks:",
                            style: TextStyle(fontSize: 24),
                          ),
                          SizedBox(
                            width: double.maxFinite,
                            height: 150,
                            child: Card(
                              elevation: 5,
                              color: const Color.fromARGB(255, 24, 24, 24),
                              child: Text("<Task name>"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );
  }
}