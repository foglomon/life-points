import 'package:flutter/material.dart';
import 'package:life_points/edit_info.dart';

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
              height: double.maxFinite,
              width: double.maxFinite,
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
                  SizedBox(
                    width: double.maxFinite,
                    height: 100,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditInfo()),
                        );
                      },
                      child: Card(
                        elevation: 5,
                        color: const Color.fromARGB(255, 24, 24, 24),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Icon(
                                Icons.account_circle_outlined,
                                color: Colors.white,
                                size: 60,
                              ),
                            ),
                            Text(
                              'Enter your details to continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
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
