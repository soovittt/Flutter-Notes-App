import 'package:flutter/material.dart';
import 'package:noteme/Helper/generateRandomUserId.dart';
import 'package:noteme/classes/PasswordUtil.dart';
import 'package:noteme/screens/authentication/Login.dart';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';

class Signup extends StatefulWidget {
  static String id = "signup_page";
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  late DynamoDB _dynamoDB;

  @override
  void initState() {
    super.initState();
    // Initialize DynamoDB client with your AWS credentials
    _dynamoDB = DynamoDB(
      region: 'us-west-1',
      credentials: AwsClientCredentials(
        accessKey: "AKIAZI2LD5HLTCJTGYUR",
        secretKey: "r/ukzFqeMqEyOi6onZXfQlHwhmcIB8ap9gVOyj4+",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Signup Page'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Replace the 'assets/logo.png' with your image path
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
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String email = _emailController.text;
                  String password = _passwordController.text;
                  String confirmPassword = _confirmPasswordController.text;
                  _signup(email, password);
                  Navigator.pushReplacementNamed(context, Login.id);
                },
                child: const Text('Signup'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, Login.id);
                },
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signup(String email, String password) async {
    try {
      await _dynamoDB.putItem(
        tableName: 'Users',
        item: {
          'userId': AttributeValue(s: email),
          'Email': AttributeValue(s: email),
          'Password': AttributeValue(s: PasswordUtils.hashPassword(password)),
        },
      );
      print('Signup successful!');
      // Navigate to another screen or perform other actions upon successful signup
    } catch (e) {
      print('Error signing up: $e');
      // Handle signup error
    }
  }
}
