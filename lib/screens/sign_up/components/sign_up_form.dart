import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../../components/custom_surfix_icon.dart';
import '../../../components/form_error.dart';
import '../../../constants.dart';
import '../../login_success/login_success_screen.dart';
import '../../../models/User.dart'; // Ensure this import is correct
import 'package:shared_preferences/shared_preferences.dart';
import '../../../providers/userProvider.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  String? conform_password;
  String? firstName;
  String? lastName;
  String? phone;
  bool remember = false;
  final List<String?> errors = [];
  bool _isLoading = false;

  void addError({String? error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  void removeError({String? error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }
Future<void> saveUserData(User user) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user', jsonEncode(user.toJson()));
}

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      var response = await http.post(
        Uri.parse('https://themarketmanager.com/api/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': conform_password,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {


    User user = User.fromJson({
      ...responseData['user'], // Existing user data
      'access_token': responseData['access_token'], // Include access_token
    });


    await saveUserData(user);
      // Update the user state in your app
Provider.of<UserProvider>(context, listen: false).setUser(user);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginSuccessScreen()),
        );
      } else {
        String errorMessage = _extractErrorMessage(responseData);
        _showErrorDialog('Registration Failed', errorMessage);
      }
    } catch (e) {
      _showErrorDialog('Error', 'An error occurred. Please try again later.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

String _extractErrorMessage(Map<String, dynamic> responseData) {
  // Check if the 'errors' key exists
  if (responseData.containsKey('errors')) {
    Map<String, dynamic> errors = responseData['errors'];
    List<String> errorMessages = [];

    errors.forEach((key, value) {
      // Assuming each key in 'errors' maps to a List of error messages
      errorMessages.addAll(value.map<String>((msg) => msg.toString()));
    });

    // Join all error messages into a single string
    return errorMessages.join('\n');
  }

  // Fallback to a general message if 'errors' key does not exist
  return responseData['message'] ?? 'An unknown error occurred';
}



  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildFirstNameFormField(),
          const SizedBox(height: 20),
          buildLastNameFormField(),
          const SizedBox(height: 20),
          buildPhoneFormField(),
          const SizedBox(height: 20),
          buildEmailFormField(),
          const SizedBox(height: 20),
          buildPasswordFormField(),
          const SizedBox(height: 20),
          buildConfirmPasswordFormField(),
          FormError(errors: errors),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _register,
            child: _isLoading ? CircularProgressIndicator() : const Text("Continue"),
          ),
        ],
      ),
    );
  }

TextFormField buildFirstNameFormField() {
  return TextFormField(
    onSaved: (newValue) => firstName = newValue,
    onChanged: (value) {
      if (value.isNotEmpty) {
        removeError(error: firstName);
      }
      return;
    },
    validator: (value) {
      if (value!.isEmpty) {
        addError(error: firstName);
        return "";
      }
      return null;
    },
    decoration: const InputDecoration(
      labelText: "First Name",
      hintText: "Enter your first name",
      floatingLabelBehavior: FloatingLabelBehavior.always,
      suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
    ),
  );
}

TextFormField buildLastNameFormField() {
  return TextFormField(
    onSaved: (newValue) => lastName = newValue,
    onChanged: (value) {
      if (value.isNotEmpty) {
        removeError(error: lastName);
      }
      return;
    },
    validator: (value) {
      if (value!.isEmpty) {
        addError(error: lastName);
        return "";
      }
      return null;
    },
    decoration: const InputDecoration(
      labelText: "Last Name",
      hintText: "Enter your last name",
      floatingLabelBehavior: FloatingLabelBehavior.always,
      suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
    ),
  );
}

TextFormField buildPhoneFormField() {
  return TextFormField(
    keyboardType: TextInputType.phone,
    onSaved: (newValue) => phone = newValue,
    onChanged: (value) {
      if (value.isNotEmpty) {
        removeError(error: kPhoneNumberNullError);
      }
      return;
    },
    validator: (value) {
      if (value!.isEmpty) {
        addError(error: kPhoneNumberNullError);
        return "";
      }
      return null;
    },
    decoration: const InputDecoration(
      labelText: "Phone Number",
      hintText: "Enter your phone number",
      floatingLabelBehavior: FloatingLabelBehavior.always,
      suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Phone.svg"),
    ),
  );
}

TextFormField buildEmailFormField() {
  return TextFormField(
    keyboardType: TextInputType.emailAddress,
    onSaved: (newValue) => email = newValue,
    onChanged: (value) {
      if (value.isNotEmpty) {
        removeError(error: kEmailNullError);
      } else if (emailValidatorRegExp.hasMatch(value)) {
        removeError(error: kInvalidEmailError);
      }
      return;
    },
    validator: (value) {
      if (value!.isEmpty) {
        addError(error: kEmailNullError);
        return "";
      } else if (!emailValidatorRegExp.hasMatch(value)) {
        addError(error: kInvalidEmailError);
        return "";
      }
      return null;
    },
    decoration: const InputDecoration(
      labelText: "Email",
      hintText: "Enter your email",
      floatingLabelBehavior: FloatingLabelBehavior.always,
      suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
    ),
  );
}

TextFormField buildPasswordFormField() {
  return TextFormField(
    obscureText: true,
    onSaved: (newValue) => password = newValue,
    onChanged: (value) {
      if (value.isNotEmpty) {
        removeError(error: kPassNullError);
      } else if (value.length >= 8) {
        removeError(error: kShortPassError);
      }
      password = value;
    },
    validator: (value) {
      if (value!.isEmpty) {
        addError(error: kPassNullError);
        return "";
      } else if (value.length < 8) {
        addError(error: kShortPassError);
        return "";
      }
      return null;
    },
    decoration: const InputDecoration(
      labelText: "Password",
      hintText: "Enter your password",
      floatingLabelBehavior: FloatingLabelBehavior.always,
      suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
    ),
  );
}

TextFormField buildConfirmPasswordFormField() {
  return TextFormField(
    obscureText: true,
    onSaved: (newValue) => conform_password = newValue,
    onChanged: (value) {
      if (value.isNotEmpty) {
        removeError(error: kPassNullError);
      } else if (value.isNotEmpty && password == conform_password) {
        removeError(error: kMatchPassError);
      }
      conform_password = value;
    },
    validator: (value) {
      if (value!.isEmpty) {
        addError(error: kPassNullError);
        return "";
      } else if ((password != value)) {
        addError(error: kMatchPassError);
        return "";
      }
      return null;
    },
    decoration: const InputDecoration(
      labelText: "Confirm Password",
      hintText: "Re-enter your password",
      floatingLabelBehavior: FloatingLabelBehavior.always,
      suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
    ),
  );
}


}
