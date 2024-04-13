import 'package:flutter/widgets.dart';

import 'screens/sign_in/components/LoginCheckWrapper.dart'; // Import LoginCheckWrapper
import 'screens/sign_in/components/HideLoginWrapper.dart'; // Import LoginCheckWrapper

import 'screens/forgot_password/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/init_screen.dart';
import 'screens/login_success/login_success_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/sign_in/sign_in_screen.dart';
import 'screens/sign_up/sign_up_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/companies/companies_screen.dart';
import 'screens/companies/menu_screen.dart';
import 'screens/assignments/assignments_screen.dart';
import 'screens/assignments/single_assignment_screen.dart';
import 'screens/assignments/pos_screen.dart';
import 'screens/assignments/reports_screen.dart';
import 'screens/assignments/sales_screen.dart';

// We use name route
// All our routes will be available here
final Map<String, WidgetBuilder> routes = {
  // Wrap screens that should be inaccessible to logged-in users
  SplashScreen.routeName: (context) =>
      HideLoginWrapper(child: const SplashScreen()),
  SignInScreen.routeName: (context) =>
      HideLoginWrapper(child: const SignInScreen()),
  ForgotPasswordScreen.routeName: (context) =>
      HideLoginWrapper(child: const ForgotPasswordScreen()),
  SignUpScreen.routeName: (context) =>
      HideLoginWrapper(child: const SignUpScreen()),

  // Other screens
  InitScreen.routeName: (context) =>      LoginCheckWrapper(child: const InitScreen()),
  LoginSuccessScreen.routeName: (context) =>      LoginCheckWrapper(child: const LoginSuccessScreen()),
  HomeScreen.routeName: (context) =>      LoginCheckWrapper(child: const HomeScreen()),
  ProfileScreen.routeName: (context) =>      LoginCheckWrapper(child: ProfileScreen()),
  CompaniesScreen.routeName: (context) =>      LoginCheckWrapper(child: CompaniesScreen()),



  MenuScreen.routeName: (context) => LoginCheckWrapper(
          child: MenuScreen(
        companySlug: '',
      )),
  SingleAssignmentScreen.routeName: (context) => LoginCheckWrapper(
      child: SingleAssignmentScreen(companySlug: '', assignmentSlug: '')),
  PosScreen.routeName: (context) =>
      LoginCheckWrapper(child: PosScreen(companySlug: '', assignmentSlug: '')),
  ReportsScreen.routeName: (context) => LoginCheckWrapper(
      child: ReportsScreen(companySlug: '', assignmentSlug: '')),
  SalesScreen.routeName: (context) => LoginCheckWrapper(
      child: SalesScreen(companySlug: '', assignmentSlug: '')),
};
