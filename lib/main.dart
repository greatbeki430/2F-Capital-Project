import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_chat_app/pages/home.dart';
import 'package:todo_chat_app/pages/login.dart';
import 'package:todo_chat_app/pages/sign_up.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:todo_chat_app/pages/todo_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyBlZnCsiifHS7inv-Ibhpo7yLwg1wkLBXY",
            authDomain: "f-capital-bce9e.firebaseapp.com",
            projectId: "f-capital-bce9e",
            storageBucket: "f-capital-bce9e.appspot.com",
            messagingSenderId: "317987809621",
            appId: "1:317987809621:web:33017c15193ac000c267dc"));
  } else {
    await Firebase.initializeApp();
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => TodoProvider()), // Add TodoProvider here
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Collaborative TODO AND CHAT APP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Use the SplashScreen as the initial route
      routes: {
        '/login': (context) => LoginPage(),
        '/signup': (context) => Signup(),
        '/home': (context) => HomePage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }

  void _checkUserLoggedIn() {
    // Use addPostFrameCallback to delay the navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // User is signed in, navigate to HomePage
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // User is not signed in, navigate to LoginPage
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Display a splash screen while checking the authentication state
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
