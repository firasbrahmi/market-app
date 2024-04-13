import 'package:flutter/material.dart';
import 'package:flutter_market_manager/screens/splash/splash_screen.dart';
import 'package:provider/provider.dart';
import 'providers/userProvider.dart';
import 'routes.dart';
import 'theme.dart';
import 'screens/profile/profile_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() {
  timeago.setLocaleMessages('en', timeago.EnMessages()); // Initialize timeago with 'en' locale
  runApp(
    ChangeNotifierProvider(
      create: (context) {
        UserProvider userProvider = UserProvider();
        userProvider.loadUserData(); // Load user data on app start
        return userProvider;
      },
      child: MyApp(),
    ),
  );
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {


          if (Provider.of<UserProvider>(context).isLoggedIn) {
    return MaterialApp(
      title: 'Assignment Details',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        cardTheme: CardTheme(
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          margin: EdgeInsets.all(8.0),
          elevation: 0,
        ),
        textTheme: TextTheme(
          headline6: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
          bodyText2: TextStyle(fontSize: 14.0, color: Colors.white70),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: const Color(0xFF3C3C3C),
        ),
      ),
      initialRoute: ProfileScreen.routeName,
      routes: routes,
          );
          }else {


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Market Manager',
      theme: AppTheme.darktTheme(context),
      initialRoute: SplashScreen.routeName,
      routes: routes,
    );
          }
  }
}
