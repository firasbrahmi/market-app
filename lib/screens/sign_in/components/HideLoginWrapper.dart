import 'package:flutter/material.dart';
import '../../../providers/userProvider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_market_manager/screens/init_screen.dart';

class HideLoginWrapper extends StatelessWidget {
  final Widget child;

  const HideLoginWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // If the user is logged in, redirect to the home screen
    if (userProvider.isLoggedIn) {
      Future.microtask(() =>
          Navigator.of(context).pushReplacementNamed(InitScreen.routeName));
    }

    // If not logged in, show the intended child widget
    return child;
  }
}
