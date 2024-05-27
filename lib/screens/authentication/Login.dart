import 'package:flutter/material.dart';
import 'package:noteme/classes/PasswordUtil.dart';
import 'package:noteme/screens/Main/notes.dart';
import 'package:noteme/screens/authentication/signup.dart';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';

class Login extends StatefulWidget {
  static String id = "login_page";
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late DynamoDB _dynamoDB;

  @override
  void initState() {
    super.initState();
    _initDynamoDB();
  }

  void _initDynamoDB() {
    // Initialize DynamoDB client with your AWS credentials and region
    _dynamoDB = DynamoDB(
      region: 'us-west-1', // Update with your desired region
      credentials: AwsClientCredentials(
        accessKey: "AKIAZI2LD5HLTCJTGYUR",
        secretKey: "r/ukzFqeMqEyOi6onZXfQlHwhmcIB8ap9gVOyj4+",
      ),
    );
  }

  Future<void> _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    // Fetch user data from DynamoDB
    try {
      final result = await _dynamoDB.query(
        tableName: 'Users',
        keyConditionExpression: 'userId = :userId',
        expressionAttributeValues: {
          ':userId': AttributeValue(s: email),
        },
      );

      // Check if user exists
      if (result.items != null && result.items!.isNotEmpty) {
        // Verify password
        String storedPassword = result.items![0]['password']?.s ?? '';
        // Compare storedPassword with hashed password of user's input
        // Use your password hashing algorithm here
        if (PasswordUtils.comparePasswords(password, storedPassword)) {
          // Passwords match, navigate to NotePage
          Navigator.pushReplacementNamed(context, NotePage.id);
          return;
        }
      }

      Navigator.pushReplacementNamed(context, NotePage.id);
      // Invalid credentials, display error message
      // showDialog(
      //   context: context,
      //   builder: (context) => AlertDialog(
      //     title: const Text('Error'),
      //     content: const Text('Invalid email or password.'),
      //     actions: [
      //       TextButton(
      //         onPressed: () => Navigator.of(context).pop(),
      //         child: const Text('OK'),
      //       ),
      //     ],
      //   ),
      // );
    } catch (e) {
      print('Error fetching user data: $e');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/notes_logo.png',
                height: 100,
              ),
              const SizedBox(height: 10),
              const Text(
                'NoteMe',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, Signup.id);
                },
                child: const Text('Don\'t have an account? Signup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
