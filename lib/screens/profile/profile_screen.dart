import 'package:flutter/material.dart';
import 'package:flutter_market_manager/screens/tasks/tasks_screen.dart';
import '../../providers/userProvider.dart';
import 'package:provider/provider.dart';

import 'components/profile_menu.dart';
import 'components/profile_pic.dart';
import '../../../screens/sign_in/sign_in_screen.dart';

class ProfileScreen extends StatefulWidget {
  static String routeName = "/profile";

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        physics:
            AlwaysScrollableScrollPhysics(), // Allows pull-to-refresh behavior
        child: Column(
          children: [
            const ProfilePic(),
            const SizedBox(height: 20),
            Text(
              user != null ? "Welcome ${user.firstName}" : "",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            ProfileMenu(
              text: "Log Out",
              icon: "assets/icons/Log out.svg",
              press: () {
                Provider.of<UserProvider>(context, listen: false)
                    .logout(context);
                Navigator.pushNamed(context, SignInScreen.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}
