import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/User.dart';
import '../models/Company.dart';
import '../models/Task.dart';
import '../models/Assignment.dart';
import '../models/AssignmentDetail.dart';
import '../models/Report.dart';
import '../models/Sales.dart';
import '../models/Pos.dart';
import '../../screens/sign_in/sign_in_screen.dart';
import 'package:http/http.dart' as http;


class SaleResponse {
  final bool success;
  final String message;

  SaleResponse({required this.success, this.message = ''});
}



class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  bool get isLoggedIn => _user != null;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void logout(BuildContext context) async {
    // Optionally, make an API call to logout the user on the server
    try {
      if (_user != null) {
        final url = Uri.parse('https://themarketmanager.com/api/logout');
        await http.post(url, headers: {
          'Authorization': 'Bearer ${_user!.accessToken}',
        });
      }
    } catch (error) {
      // Handle or log error if necessary
      print("Logout error: $error");
    }

    // Clear user data from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user');

    // Reset the user state
    _user = null;
    _userCompanies.clear();

    notifyListeners();

    // Navigate to the Sign In screen
    Navigator.pushReplacementNamed(context, SignInScreen.routeName);
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      _user = User.fromJson(jsonDecode(userJson));
      notifyListeners();
    }
  }

  List<UserCompany> _userCompanies = [];

  List<UserCompany> get userCompanies => _userCompanies;

  Future<void> fetchUserCompanies(String accessToken) async {
    final url =
        Uri.parse('https://themarketmanager.com/api/select-company-menu');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final loadedCompanies = (responseData['userCompanies'] as List)
            .map((companyData) => UserCompany.fromJson(companyData))
            .toList();

        _userCompanies = loadedCompanies;
        notifyListeners();
      }
    } catch (error) {
      // handle error
    }
  }

  Future<List<Assignment>> fetchAssignments(
      String accessToken, String companySlug) async {
    final url = Uri.parse(
        'https://themarketmanager.com/api/company/$companySlug/assignments');
    List<Assignment> assignments = [];
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as List;
        assignments = responseData
            .map((assignmentData) => Assignment.fromJson(assignmentData))
            .toList();
      }
    } catch (error) {
      // Handle error
    }
    return assignments;
  }

Future<AssignmentDetail> fetchAssignmentDetails(
    String accessToken, String companySlug, String assignmentSlug) async {
  final url = Uri.parse(
      'https://themarketmanager.com/api/company/$companySlug/assignment/$assignmentSlug');

  try {
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      // Include both 'assignment' and 'equipments' in the response
      return AssignmentDetail.fromJson({
        'assignment': responseData['assignment'],
        'equipments': responseData['equipments'] ?? [], // Handle the case if equipments is null
      });
    } else {
      // Handle non-200 responses
      throw Exception('Failed to load assignment details');
    }
  } catch (e) {
    // Handle any errors
    throw Exception('Error fetching assignment details: $e');
  }
}








Future<Sales> fetchSales(
    String accessToken, String companySlug, String assignmentSlug) async {
  final url = Uri.parse(
      'https://themarketmanager.com/api/company/$companySlug/assignment/$assignmentSlug/sales');

  try {
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      return Sales.fromJson({
        'sales': responseData['sales'],
        'products': responseData['products'] ?? [], 
      });
    } else {
      // Handle non-200 responses
      throw Exception('Failed to load sales details');
    }
  } catch (e) {
    // Handle any errors
    throw Exception('Error fetching sales details: $e');
  }
}










Future<Pos> fetchPos(
    String accessToken, String companySlug, String assignmentSlug) async {
  final url = Uri.parse(
      'https://themarketmanager.com/api/company/$companySlug/assignment/$assignmentSlug/pos');

  try {
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      return Pos.fromJson({
        'categories': responseData['categories'],
        'company': responseData['company'],
      });
    } else {
      // Handle non-200 responses
      throw Exception('Failed to load sales details');
    }
  } catch (e) {
    // Handle any errors
    throw Exception('Error fetching sales details: $e');
  }
}














Future<SaleResponse> submitSale(String accessToken, String companySlug, String assignmentSlug, Map<String, dynamic> saleData) async {
  final String apiUrl =
    'https://themarketmanager.com/api/company/$companySlug/assignment/$assignmentSlug/sale/store';
  try {
    final response = await http.put(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(saleData),
    );
    final responseData = json.decode(response.body);
    if (response.statusCode == 200 && responseData['error'] != true) {
      return SaleResponse(success: true, message: 'Sale submitted successfully');
    } else {
      String message = responseData['message'] ?? 'Failed to submit Sale';
      return SaleResponse(success: false, message: message);
    }
  } catch (e) {
    return SaleResponse(success: false, message: 'Error occurred Check Card Info: $e');
  }
}












Future<Reports> fetchReport(
    String accessToken, String companySlug, String assignmentSlug) async {
  final url = Uri.parse(
      'https://themarketmanager.com/api/company/$companySlug/assignment/$assignmentSlug/reports');

  try {
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return Reports.fromJson(responseData);
    } else {
      throw Exception('Failed to load report details');
    }
  } catch (e) {
    throw Exception('Error fetching report details: $e');
  }
}




Future<void> submitReport(String accessToken, String companySlug, 
    String assignmentSlug, Map<String, dynamic> reportData) async {
    final String apiUrl =
      'https://themarketmanager.com/api/company/$companySlug/assignment/$assignmentSlug/reports/store';
    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken', // Include the access token
      },
      body: jsonEncode(reportData),
    );

    if (response.statusCode == 200) {
      // Handle successful response
    } else {
      // Handle error response
      print('Failed to submit report: ${response.body}');
    }
  } catch (e) {
    // Handle network or other errors
    print('Error occurred while submitting report: $e');
  }
}
























  Future<List<Task>> fetchTasks(String accessToken, String companySlug) async {
    final url = Uri.parse(
        'https://themarketmanager.com/api/company/$companySlug/tasks');
    List<Task> tasks = [];
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as List;
        tasks =
            responseData.map((taskData) => Task.fromJson(taskData)).toList();
      }
    } catch (error) {
      // Handle error
    }

    return tasks;
  }

  Future<Task> fetchTaskDetails(
      String accessToken, String companySlug, int taskId) async {
    final url = Uri.parse(
        'https://themarketmanager.com/api/company/$companySlug/task/$taskId');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Task.fromJson(responseData['task']);
      } else {
        // Handle different status codes or throw an error
        throw Exception('Failed to load task');
      }
    } catch (error) {
      // Handle network error
      throw Exception('Failed to load task: $error');
    }
  }

  Future<bool> updateTaskStatus(String accessToken, String companySlug,
      int taskId, int subTaskId, bool newStatus) async {
    final String apiUrl =
        'https://themarketmanager.com/api/company/$companySlug/task/$taskId';

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'sub_tasks': [
            {
              'id': subTaskId,
              'status': newStatus ? 1 : 0,
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        // Handle successful response
        return true;
      } else {
        // Extract the error message from response body
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        String errorMessage = responseData['error'] ?? 'Unknown error occurred';
        throw Exception('Failed to update task: $errorMessage');
      }
    } catch (error) {
      // Handle network error or server response error
      throw Exception('Failed to update task: $error');
    }
  }
}
