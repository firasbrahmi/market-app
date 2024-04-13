import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/userProvider.dart';
import '../../models/Task.dart';
import 'single_task_screen.dart';

class TasksScreen extends StatefulWidget {
  final String companySlug;

  TasksScreen({Key? key, required this.companySlug}) : super(key: key);

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late Future<List<Task>> tasksFuture;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      // Fetch the tasks and assign them to tasksFuture
      tasksFuture = userProvider.fetchTasks(userProvider.user!.accessToken!, widget.companySlug);
      // Await the tasksFuture
      await tasksFuture;
      // Call setState to trigger a rebuild of the UI
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching tasks: $error')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks for ${widget.companySlug}'),
      backgroundColor: Color.fromARGB(15, 16, 20, 0), // Lighter background
        elevation: 2,

      ),
      body: RefreshIndicator(
        onRefresh: _fetchTasks,
        child: FutureBuilder<List<Task>>(
          future: tasksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var task = snapshot.data![index];
                  return _buildTaskCard(context, task);
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 50, color: Colors.grey),
          SizedBox(height: 10),
          Text('No tasks found', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

Card _buildTaskCard(BuildContext context, Task task) {
  int priorityValue = int.tryParse(task.priority) ?? 0;
  Map<String, dynamic> priorityInfo = _formatPriority(priorityValue);
  String priorityText = priorityInfo['text'];
  Color priorityColor = priorityInfo['color'];
  IconData statusIcon = task.status ? Icons.check_circle : Icons.pending;
  Color statusColor = task.status ? Colors.green : Colors.blue;

  return Card(
    color: const Color.fromARGB(15, 16, 20, 0), // Set the background color to black
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 3,
    margin: EdgeInsets.all(10),
    child: InkWell(
      onTap: () => navigateToSingleTaskScreen(context, widget.companySlug, task.id),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              child: Icon(Icons.task, color: Colors.white),
              backgroundColor: priorityColor,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      task.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Type: ${task.type}'),
                    Text('Priority: $priorityText', style: TextStyle(color: priorityColor)),
                    Text('Due Date: ${task.dueDate ?? 'No due date'}'),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor),
                        SizedBox(width: 4),
                        Text(task.status ? 'Completed' : 'Pending', style: TextStyle(color: statusColor)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _buildViewButton(context, task),
          ],
        ),
      ),
    ),
  );
}





Widget _buildViewButton(BuildContext context, Task task) {
  return SizedBox(
    width: 100, // Set a fixed width for the button
    child: ElevatedButton(
      onPressed: () => navigateToSingleTaskScreen(context, widget.companySlug, task.id),
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


  void navigateToSingleTaskScreen(BuildContext context, String companySlug, int id) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SingleTaskScreen(companySlug: companySlug, id: id),
      ),
    );
  }

// Method to format the priority
Map<String, dynamic> _formatPriority(int priority) {
  String text;
  Color color;

  switch (priority) {
    case 0:
      text = 'Low';
      color = Colors.green;
      break;
    case 1:
      text = 'Medium';
      color = Colors.orange;
      break;
    case 2:
      text = 'High';
      color = Colors.red;
      break;
    default:
      text = 'Unknown';
      color = Colors.grey;
  }

  return {'text': text, 'color': color};
}

}
