import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_market_manager/screens/companies/menu_screen.dart';
import '../../../providers/userProvider.dart';
import 'package:flutter_market_manager/screens/tasks/tasks_screen.dart';

import '../profile/components/companies_menu.dart';

class CompaniesScreen extends StatefulWidget {
  static String routeName = "/companies";

  @override
  _CompaniesScreenState createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    // Load user data when the screen is initially displayed
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user != null) {
      userProvider.fetchUserCompanies(user.accessToken!);
    }
  }

  void navigateToMenuScreen(BuildContext context, String companySlug) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MenuScreen(companySlug: companySlug),
      ),
    );
  }

  Future<void> _refreshData(BuildContext context) async {
    // Show loading indicator while refreshing
    setState(() {
      _isLoading = true;
    });
    // Reload user data when the user performs a refresh
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user != null) {
      await userProvider.fetchUserCompanies(user.accessToken!);
    }

    // Hide loading indicator when data refresh is complete
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Companies"),
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshData(context),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          physics:
              AlwaysScrollableScrollPhysics(), // Allows pull-to-refresh behavior
          child: Column(
            children: [
              // Display the company information
              for (var company in userProvider.userCompanies)
                CompaniesMenu(
                  text: company.details.name,
                  imageUrl: company.details.image != null
                      ? "https://themarketmanager.com/${company.details.image}"
                      : "https://themarketmanager.com/assets/media/image.png", // Provide the fallback image URL
                  press: () {
                    navigateToMenuScreen(context, company.details.slug);
                  },
                ),
              if (_isLoading) // Show loading indicator while refreshing
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
