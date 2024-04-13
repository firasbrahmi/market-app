import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/Task.dart';
import '../../../providers/userProvider.dart';
import 'package:provider/provider.dart';


class SingleTaskScreen extends StatefulWidget {
  final String companySlug;
  final int id;

  const SingleTaskScreen({Key? key, required this.companySlug, required this.id}) : super(key: key);

  @override
  _SingleTaskScreenState createState() => _SingleTaskScreenState();
}

class _SingleTaskScreenState extends State<SingleTaskScreen> {
  late Future<Task> taskFuture;

  @override
  void initState() {
    super.initState();
    taskFuture = _initializeTask();
  }

  Future<Task> _initializeTask() async {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      return await userProvider.fetchTaskDetails(
        userProvider.user!.accessToken!,
        widget.companySlug,
        widget.id,
      );
    } catch (e) {
      // Improved error handling
      debugPrint('Error fetching task: $e');
      // Consider using a more user-friendly error message
      throw Exception('Failed to load task. Please try again later.');
    }
  }

  Future<void> _refreshTaskDetails() async {
    setState(() {
      taskFuture = _initializeTask();
    });
  }





  void _showLoadingIndicator(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(15, 16, 20, 0), // Lighter background
      appBar: AppBar(
      title: Text('Task Details', style: GoogleFonts.nunitoSans(color: Colors.white)), // Set text color to white
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTaskDetails,
        child: FutureBuilder<Task>(
          future: taskFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No task found'));
          } else {
            var task = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildSection('Task Information', [
                    _buildInfoRow('Name', task.name),
                    _buildInfoRow('Priority', task.priority),
                    _buildInfoRow('Recurring', task.recurring ? 'Yes' : 'No'),
                    _buildInfoRow('Details', task.details),
                  ]),
                  const SizedBox(height: 16),
                  _buildProgressIndicator(task.progress),
                  const SizedBox(height: 16),
                  _buildSection('Sub Tasks', task.subTasks.map((subTask) => _buildSubTaskCard(task, subTask)).toList()),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            );
          }
        },
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> content) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(15, 16, 20, 0),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 23, 28, 1).withOpacity(0.2),
            spreadRadius: 2,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, 
            style: GoogleFonts.nunitoSans(color: Colors.indigo, fontSize: 20, fontWeight: FontWeight.bold)
          ),
          ...content,
        ],
      ),
    );
  }

Widget _buildInfoRow(String label, dynamic value) {
  // Handle the display of priority specifically
  if (label == 'Priority') {
    // Convert the value to int if it's a string
    int priorityValue = (value is String) ? int.tryParse(value) ?? 0 : value;
    var priorityDisplay = _formatPriority(priorityValue);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 18)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: priorityDisplay['color'],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(priorityDisplay['text'], style: const TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ],
      ),
    );
  } else {
    // Original handling for other info rows
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 18)),
          Text(value.toString(), style: const TextStyle(color: Colors.white, fontSize: 18)),
        ],
      ),
    );
  }
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

  double calculateTaskProgress(Task task) {
    List<Task> subTasks = task.subTasks;
    if (subTasks.isEmpty) {
      return 0.0;
    }
    int completedCount = subTasks.where((subTask) => subTask.status).length;
    return (completedCount / subTasks.length) * 100.0;
  }

Widget _buildProgressIndicator(double progress) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Task Progress', style: GoogleFonts.nunito(color: Colors.white, fontSize: 18)),
      const SizedBox(height: 4),
      Stack(
        children: [
          Container(
            width: double.infinity,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * (progress / 100.0),
            height: 20,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
      SizedBox(height: 4),
    ],
  );
}

Widget _buildSubTaskCard(Task task, Task subTask) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.grey[850],
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subTask.name, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text(subTask.details, style: TextStyle(color: Colors.white70, fontSize: 14)),
          SizedBox(height: 6),
          Text('Estimated Time: ${subTask.estimatedTime}', style: TextStyle(color: Colors.white60, fontSize: 13)),
          Divider(color: Colors.grey[700], height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusIndicator(subTask.status),
              _buildStatusToggleSwitch(task, subTask),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildStatusIndicator(bool status) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: status ? Colors.green : Colors.red,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      status ? 'Completed' : 'Pending',
      style: TextStyle(color: Colors.white, fontSize: 12),
    ),
  );
}

Widget _buildStatusToggleSwitch(Task task, Task subTask) {
  return Switch(
    value: subTask.status,
          onChanged: (bool newValue) async {
            try {
              UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
              _showLoadingIndicator(context);

              bool isUpdateSuccessful = await userProvider.updateTaskStatus(
                userProvider.user!.accessToken!,
                widget.companySlug,
                widget.id,
                subTask.id,
                newValue,
              );

              Navigator.of(context).pop();

              if (isUpdateSuccessful) {
                setState(() {
                  subTask.status = newValue;
                  task.progress = calculateTaskProgress(task);
                });
              } else {
                _showErrorSnackBar(context, 'Failed to update task status');
              }
            } catch (error) {
              Navigator.of(context).pop();
              _showErrorSnackBar(context, 'An error occurred');
            }
          },
    activeColor: Colors.indigo,
  );
}


  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildButton('Close', Colors.redAccent)),
        const SizedBox(width: 8),
      ],
    );
  }

Widget _buildButton(String text, Color color) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(primary: color),
    onPressed: () {
        Navigator.pop(context);
      },
      child: Text(text, style: const TextStyle(fontSize: 18)),
    );
  }
}
