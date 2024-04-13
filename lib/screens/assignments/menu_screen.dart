import 'package:flutter/material.dart';
import 'single_assignment_screen.dart';
import 'pos_screen.dart';
import 'reports_screen.dart';
import 'sales_screen.dart';

class AssignmentMenu extends StatelessWidget {
  final String companySlug;
  final String assignmentSlug;

  AssignmentMenu({
    required this.companySlug,
    required this.assignmentSlug,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      height: 80, // Increased height for better touch targets
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        borderRadius: BorderRadius.circular(10.0), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Shadow color
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildTabItem(context, icon: Icons.report, text: 'Overview', page: SingleAssignmentScreen(assignmentSlug: assignmentSlug, companySlug: companySlug,)),
          _buildTabItem(context, icon: Icons.point_of_sale, text: 'POS', page: PosScreen(assignmentSlug: assignmentSlug, companySlug: companySlug,)),
          _buildTabItem(context, icon: Icons.shopping_cart, text: 'Sales', page: SalesScreen(assignmentSlug: assignmentSlug, companySlug: companySlug,)),
          _buildTabItem(context, icon: Icons.bar_chart, text: 'Reports', page: ReportsScreen(assignmentSlug: assignmentSlug, companySlug: companySlug,)),
        ],
      ),
    );
  }

Widget _buildTabItem(BuildContext context, {required IconData icon, required String text, required Widget page}) {
  return GestureDetector(
    onTap: () {
      bool isNewRouteSameAsCurrent = false;

      // Check if the topmost route in the stack is the same as the page we want to navigate to
      Navigator.popUntil(context, (route) {
        if (route.settings.name == page.runtimeType.toString()) {
          isNewRouteSameAsCurrent = true;
        }
        return true;
      });

      // If the new route is different, navigate to it
      if (!isNewRouteSameAsCurrent) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      }
    },
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(icon, color: Colors.blue),
        SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

}