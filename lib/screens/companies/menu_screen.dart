import 'package:flutter/material.dart';
import '../tasks/tasks_screen.dart';
import '../assignments/assignments_screen.dart';

class MenuScreen extends StatelessWidget {
  static String routeName = "/menu";

  final String companySlug;

  MenuScreen({required this.companySlug});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Option'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text('Go to Markets'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AssignmentsScreen(companySlug: companySlug),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Go to Tasks'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TasksScreen(companySlug: companySlug),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
