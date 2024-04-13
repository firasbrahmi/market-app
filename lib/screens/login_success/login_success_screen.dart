import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/userProvider.dart';
import '../profile/components/profile_pic.dart';
import 'package:flutter_market_manager/screens/init_screen.dart';

class LoginSuccessScreen extends StatelessWidget {
  static String routeName = "/login_success";

  const LoginSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        title: const Text("Login Success"),
      ),
      body: Column(
        children: [
          // Display the profile picture widget at the top
          const SizedBox(height: 16),
          ProfilePic(), // Assuming this widget is correctly imported and used

          const SizedBox(height: 16),
          Image.asset(
            "assets/images/success.png",
            height: MediaQuery.of(context).size.height * 0.4, //40%
          ),
          const SizedBox(height: 16),
          Text(
            user != null ? "Welcome ${user.firstName}" : "Login Success",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, InitScreen.routeName);
              },
              child: const Text("Go to Dashboard"),
            ),
          ),
          const Spacer(),

          // ... other widgets ...
        ],
      ),
    );
  }
}
