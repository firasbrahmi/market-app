import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/userProvider.dart';
import '../../models/Assignment.dart';
import 'single_assignment_screen.dart';

class AssignmentsScreen extends StatefulWidget {
  final String companySlug;

  AssignmentsScreen({Key? key, required this.companySlug}) : super(key: key);

  @override
  _AssignmentsScreenState createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  late Future<List<Assignment>> assignmentsFuture;

  @override
  void initState() {
    super.initState();
    _fetchAssignments();
  }

  Future<void> _fetchAssignments() async {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      // Fetch the assignments and assign them to assignmentsFuture
      assignmentsFuture = userProvider.fetchAssignments(userProvider.user!.accessToken!, widget.companySlug);
      // Await the assignmentsFuture
      await assignmentsFuture;
      // Call setState to trigger a rebuild of the UI
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching assignments: $error')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assignments for ${widget.companySlug}'),
      backgroundColor: Color.fromARGB(15, 16, 20, 0), // Lighter background
        elevation: 2,

      ),
      body: RefreshIndicator(
        onRefresh: _fetchAssignments,
        child: FutureBuilder<List<Assignment>>(
          future: assignmentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var assignment = snapshot.data![index];
                  return _buildAssignmentCard(context, assignment);
                },
              );
            }
          },
        ),
      ),
    );
  }


Card _buildAssignmentCard(BuildContext context, Assignment assignment) {
  IconData statusIcon = assignment.status ? Icons.check_circle : Icons.pending;
  Color statusColor = assignment.status ? Colors.green : Colors.blue;

  return Card(
    color: const Color.fromARGB(15, 16, 20, 0), // Set the background color to black
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 3,
    margin: EdgeInsets.all(10),
    child: InkWell(
      onTap: () => navigateToSingleAssignmentScreen(context, widget.companySlug, assignment.slug),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(assignment.slug, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 4),
            Text('Market: ${assignment.marketName}', style: TextStyle(fontSize: 16, color: Colors.deepPurple)),
            SizedBox(height: 4),
            Text('Day: ${assignment.day}'),
            Text('Time: ${_formatTime(assignment.start_time)} - ${_formatTime(assignment.end_time)}'),
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor),
                SizedBox(width: 4),
                Text(assignment.status ? 'Completed' : 'Pending', style: TextStyle(color: statusColor)),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

String _formatTime(String? time) {
  // Implement time formatting logic here if needed
  return time ?? 'Not specified';
}







Widget _buildViewButton(BuildContext context, Assignment assignment) {
  return SizedBox(
    width: 100, // Set a fixed width for the button
    child: ElevatedButton(
      onPressed: () => navigateToSingleAssignmentScreen(context, widget.companySlug, assignment.slug),
      style: ElevatedButton.styleFrom(
        primary: Colors.blueAccent, // Custom button color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners
        ),
      ),
      child: Text('View'),
    ),
  );
}


  void navigateToSingleAssignmentScreen(BuildContext context, String companySlug, String assignmentSlug) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SingleAssignmentScreen(companySlug: companySlug, assignmentSlug: assignmentSlug),
      ),
    );
  }


}
