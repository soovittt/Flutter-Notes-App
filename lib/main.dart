import 'package:flutter/material.dart';
import 'package:noteme/providers/NotesProvider.dart';
import 'package:noteme/screens/Main/notes.dart';
import 'package:noteme/screens/authentication/Login.dart';
import 'package:noteme/screens/authentication/signup.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NotesProvider()),
      ],
      child: MaterialApp(
        title: 'NoteMe',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(
          useMaterial3: true,
        ),
        initialRoute: Login.id,
        routes: {
          Login.id: (context) => const Login(),
          Signup.id: (context) => const Signup(),
          NotePage.id: (context) => const NotePage(),
        },
      ),
    );
  }
}
